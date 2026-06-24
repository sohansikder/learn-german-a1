/* ═══════════════════════════════════════════════════════════
   AUTH.JS — Firebase Authentication + Firestore Cloud Sync
   DeutschBlitz — German A1 Learning Platform
   ═══════════════════════════════════════════════════════════ */

// ── Firebase Configuration ──
// IMPORTANT: Replace these values with YOUR Firebase project config.
// Get them from: Firebase Console → Project Settings → Your App → Config
const FIREBASE_CONFIG = {
  apiKey: "AIzaSyAn3ONHlCsfGZH828xNefgnilQKC8Eqpgk",
  authDomain: "deutschblitz-a0e61.firebaseapp.com",
  projectId: "deutschblitz-a0e61",
  storageBucket: "deutschblitz-a0e61.firebasestorage.app",
  messagingSenderId: "940190454500",
  appId: "1:940190454500:web:a6001319f6bc3fef0952f1",
  measurementId: "G-MKE6QHC9DF"
};

// ── Initialize Firebase ──
let db_auth = null;
let db_firestore = null;
let db_currentUser = null;

function initFirebase() {
  try {
    // Check if Firebase SDK is loaded
    if (typeof firebase === "undefined") {
      console.warn(
        "[DeutschBlitz Auth] Firebase SDK not loaded. Running in guest mode.",
      );
      return false;
    }

    // Initialize only once
    if (!firebase.apps.length) {
      firebase.initializeApp(FIREBASE_CONFIG);
    }

    db_auth = firebase.auth();
    db_firestore = firebase.firestore();

    // Listen for auth state changes
    db_auth.onAuthStateChanged(handleAuthStateChanged);

    console.log("[DeutschBlitz Auth] Firebase initialized.");
    return true;
  } catch (err) {
    console.error("[DeutschBlitz Auth] Firebase init error:", err);
    return false;
  }
}

// ═══════════════════════════════════════════════════════════
// AUTH FUNCTIONS
// ═══════════════════════════════════════════════════════════

async function authSignUp(email, password, displayName) {
  try {
    showAuthLoading(true);
    const cred = await db_auth.createUserWithEmailAndPassword(email, password);

    // Set display name
    await cred.user.updateProfile({
      displayName: displayName || email.split("@")[0],
    });

    // Create user document in Firestore
    await db_firestore
      .collection("users")
      .doc(cred.user.uid)
      .set({
        displayName: displayName || email.split("@")[0],
        email: email,
        createdAt: firebase.firestore.FieldValue.serverTimestamp(),
      });

    // Merge any existing local progress into cloud
    await mergeLocalProgressToCloud(cred.user.uid);

    closeAuthModal();
    showAuthLoading(false);
    return { success: true };
  } catch (err) {
    showAuthLoading(false);
    return { success: false, error: friendlyError(err.code) };
  }
}

async function authSignIn(email, password) {
  try {
    showAuthLoading(true);
    await db_auth.signInWithEmailAndPassword(email, password);
    closeAuthModal();
    showAuthLoading(false);
    return { success: true };
  } catch (err) {
    showAuthLoading(false);
    return { success: false, error: friendlyError(err.code) };
  }
}

async function authSignInWithGoogle() {
  try {
    showAuthLoading(true);
    const provider = new firebase.auth.GoogleAuthProvider();
    const cred = await db_auth.signInWithPopup(provider);

    // Create user doc if first time
    const userDoc = await db_firestore
      .collection("users")
      .doc(cred.user.uid)
      .get();
    if (!userDoc.exists) {
      await db_firestore
        .collection("users")
        .doc(cred.user.uid)
        .set({
          displayName: cred.user.displayName || cred.user.email.split("@")[0],
          email: cred.user.email,
          createdAt: firebase.firestore.FieldValue.serverTimestamp(),
        });
      await mergeLocalProgressToCloud(cred.user.uid);
    }

    closeAuthModal();
    showAuthLoading(false);
    return { success: true };
  } catch (err) {
    showAuthLoading(false);
    if (err.code === "auth/popup-closed-by-user")
      return { success: false, error: null };
    return { success: false, error: friendlyError(err.code) };
  }
}

async function authSignOut() {
  try {
    await db_auth.signOut();
    closeUserDropdown();
  } catch (err) {
    console.error("[DeutschBlitz Auth] Sign out error:", err);
  }
}

// ═══════════════════════════════════════════════════════════
// PROGRESS SYNC (Firestore)
// ═══════════════════════════════════════════════════════════

async function saveProgressToCloud(data) {
  if (!db_currentUser || !db_firestore) return;

  try {
    await db_firestore
      .collection("users")
      .doc(db_currentUser.uid)
      .collection("data")
      .doc("progress")
      .set(data, { merge: true });

    // Also save locally as cache
    localStorage.setItem("db_gameState", JSON.stringify(data));
    showSyncStatus("synced");
  } catch (err) {
    console.error("[DeutschBlitz Auth] Save to cloud failed:", err);
    showSyncStatus("error");
  }
}

async function loadProgressFromCloud() {
  if (!db_currentUser || !db_firestore) return null;

  try {
    const doc = await db_firestore
      .collection("users")
      .doc(db_currentUser.uid)
      .collection("data")
      .doc("progress")
      .get();

    if (doc.exists) {
      const data = doc.data();
      // Update local cache
      localStorage.setItem("db_gameState", JSON.stringify(data));
      return data;
    }
    return null;
  } catch (err) {
    console.error("[DeutschBlitz Auth] Load from cloud failed:", err);
    return null;
  }
}

async function mergeLocalProgressToCloud(uid) {
  const localData = JSON.parse(localStorage.getItem("db_gameState") || "{}");
  if (Object.keys(localData).length === 0) return;

  try {
    const cloudDoc = await db_firestore
      .collection("users")
      .doc(uid)
      .collection("data")
      .doc("progress")
      .get();

    let merged = { ...localData };

    if (cloudDoc.exists) {
      const cloudData = cloudDoc.data();
      // Keep the higher values (best of local & cloud)
      merged = {
        xp: Math.max(cloudData.xp || 0, localData.xp || 0),
        level: Math.max(cloudData.level || 1, localData.level || 1),
        streak: Math.max(cloudData.streak || 0, localData.streak || 0),
        lastActive:
          localData.lastActive ||
          cloudData.lastActive ||
          new Date().toISOString(),
        trainers: {
          articles: mergeBest(
            cloudData.trainers?.articles,
            localData.trainers?.articles,
          ),
          verbs: mergeBest(
            cloudData.trainers?.verbs,
            localData.trainers?.verbs,
          ),
          sentences: mergeBest(
            cloudData.trainers?.sentences,
            localData.trainers?.sentences,
          ),
          vocab: mergeBest(
            cloudData.trainers?.vocab,
            localData.trainers?.vocab,
          ),
        },
      };
    }

    await db_firestore
      .collection("users")
      .doc(uid)
      .collection("data")
      .doc("progress")
      .set(merged, { merge: true });

    localStorage.setItem("db_gameState", JSON.stringify(merged));
  } catch (err) {
    console.error("[DeutschBlitz Auth] Merge error:", err);
  }
}

function mergeBest(cloud, local) {
  if (!cloud && !local) return {};
  if (!cloud) return local;
  if (!local) return cloud;
  return {
    totalCorrect: Math.max(cloud.totalCorrect || 0, local.totalCorrect || 0),
    totalAttempts: Math.max(cloud.totalAttempts || 0, local.totalAttempts || 0),
    bestStreak: Math.max(cloud.bestStreak || 0, local.bestStreak || 0),
    bestAccuracy: Math.max(cloud.bestAccuracy || 0, local.bestAccuracy || 0),
  };
}

// ═══════════════════════════════════════════════════════════
// UNIVERSAL SAVE FUNCTION (used by all trainers)
// ═══════════════════════════════════════════════════════════

function dbSaveXP(amount, trainerName, stats) {
  const saved = JSON.parse(localStorage.getItem("db_gameState") || "{}");
  saved.xp = (saved.xp || 0) + amount;
  saved.level = saved.level || 1;
  saved.lastActive = new Date().toISOString();

  const xpNeeded = saved.level * 100;
  if (saved.xp >= xpNeeded) {
    saved.xp -= xpNeeded;
    saved.level++;
  }

  // Save trainer-specific stats
  if (trainerName && stats) {
    if (!saved.trainers) saved.trainers = {};
    const prev = saved.trainers[trainerName] || {};
    saved.trainers[trainerName] = {
      totalCorrect: (prev.totalCorrect || 0) + (stats.correct || 0),
      totalAttempts: (prev.totalAttempts || 0) + (stats.total || 0),
      bestStreak: Math.max(prev.bestStreak || 0, stats.bestStreak || 0),
      bestAccuracy: Math.max(prev.bestAccuracy || 0, stats.accuracy || 0),
    };
  }

  localStorage.setItem("db_gameState", JSON.stringify(saved));

  // If logged in, also save to cloud
  if (db_currentUser) {
    saveProgressToCloud(saved);
  }

  // Update navbar counters if on main page
  if (typeof updateNavbarCounters === "function") {
    updateNavbarCounters();
  }
}

/* ═══════════════════════════════════════════════════════════
   GLOBAL PROGRESS SYNC UI
   ═══════════════════════════════════════════════════════════ */

window.updateNavbarCounters = function() {
  const widget = document.getElementById("global-progress-widget");
  const levelDisplay = document.getElementById("nav-level-display");
  const xpFill = document.getElementById("nav-xp-fill");
  const xpText = document.getElementById("nav-xp-text");

  if (!widget) return;

  try {
    const rawData = localStorage.getItem("db_gameState");
    if (rawData) {
      const data = JSON.parse(rawData);
      const level = data.level || 1;
      const xp = data.xp || 0;
      const nextLevelXP = level * 500;
      
      if(levelDisplay) levelDisplay.textContent = `Lvl ${level}`;
      if(xpText) xpText.textContent = `${xp} / ${nextLevelXP} XP`;
      
      if(xpFill) {
        const percentage = Math.min((xp / nextLevelXP) * 100, 100);
        xpFill.style.width = `${percentage}%`;
      }
      
      widget.style.display = "flex";
    } else {
      widget.style.display = "none";
    }
  } catch (err) {
    console.error("Error reading db_gameState:", err);
  }
};

// Initial setup on load if data exists
document.addEventListener("DOMContentLoaded", () => {
  if (localStorage.getItem("db_gameState")) {
    window.updateNavbarCounters();
  }
});


// ═══════════════════════════════════════════════════════════
// AUTH STATE HANDLER
// ═══════════════════════════════════════════════════════════

async function handleAuthStateChanged(user) {
  db_currentUser = user;
  updateAuthUI(user);

  if (user) {
    // Load cloud progress
    const cloudData = await loadProgressFromCloud();
    if (cloudData) {
      localStorage.setItem("db_gameState", JSON.stringify(cloudData));
    }

    // Update counters on main page
    if (typeof updateNavbarCounters === "function") {
      updateNavbarCounters();
    }

    showSyncStatus("synced");
    console.log(
      `[DeutschBlitz Auth] Signed in as ${user.displayName || user.email}`,
    );
  } else {
    showSyncStatus(null);
    console.log("[DeutschBlitz Auth] Signed out — guest mode.");
  }
}

// ═══════════════════════════════════════════════════════════
// UI FUNCTIONS
// ═══════════════════════════════════════════════════════════

function updateAuthUI(user) {
  const loginBtn = document.getElementById("auth-login-btn");
  const userWidget = document.getElementById("auth-user-widget");

  if (!loginBtn || !userWidget) return;

  if (user) {
    loginBtn.style.display = "none";
    userWidget.style.display = "flex";

    const avatarEl = userWidget.querySelector(".navbar__user-avatar");
    const nameEl = userWidget.querySelector(".navbar__user-name");

    if (avatarEl) {
      const initial = (user.displayName || user.email || "?")[0].toUpperCase();
      avatarEl.textContent = initial;
    }
    if (nameEl) {
      nameEl.textContent = user.displayName || user.email.split("@")[0];
    }
  } else {
    loginBtn.style.display = "inline-flex";
    userWidget.style.display = "none";
  }
}

function openAuthModal(mode = "login") {
  const overlay = document.getElementById("auth-overlay");
  if (!overlay) return;

  overlay.classList.add("active");
  setAuthMode(mode);
  clearAuthError();

  // Focus first input
  setTimeout(() => {
    const firstInput = overlay.querySelector(".auth-form__input");
    if (firstInput) firstInput.focus();
  }, 300);
}

function closeAuthModal() {
  const overlay = document.getElementById("auth-overlay");
  if (overlay) overlay.classList.remove("active");
}

function setAuthMode(mode) {
  const title = document.getElementById("auth-modal-title");
  const subtitle = document.getElementById("auth-modal-subtitle");
  const submitBtn = document.getElementById("auth-submit-btn");
  const nameGroup = document.getElementById("auth-name-group");
  const toggleText = document.getElementById("auth-toggle-text");
  const toggleLink = document.getElementById("auth-toggle-link");
  const emoji = document.getElementById("auth-modal-emoji");
  const passwordInput = document.getElementById("auth-password");

  if (mode === "signup") {
    if (title) title.textContent = "Create Account";
    if (subtitle) subtitle.textContent = "Start tracking your German progress";
    if (submitBtn) {
      submitBtn.textContent = "🚀 Sign Up";
      submitBtn.dataset.mode = "signup";
    }
    if (nameGroup) nameGroup.style.display = "flex";
    if (document.getElementById("auth-password-group")) document.getElementById("auth-password-group").style.display = "flex";
    if (document.getElementById("auth-divider")) document.getElementById("auth-divider").style.display = "flex";
    if (document.getElementById("auth-google-btn")) document.getElementById("auth-google-btn").style.display = "flex";
    if (passwordInput) passwordInput.required = true;
    if (toggleText) toggleText.textContent = "Already have an account? ";
    if (toggleLink) {
      toggleLink.textContent = "Log in";
      toggleLink.onclick = () => setAuthMode("login");
    }
    if (emoji) emoji.textContent = "🚀";
  } else if (mode === "reset") {
    if (title) title.textContent = "Reset Password";
    if (subtitle) subtitle.textContent = "Enter your email to receive a reset link";
    if (submitBtn) {
      submitBtn.textContent = "✉️ Send Reset Link";
      submitBtn.dataset.mode = "reset";
    }
    if (nameGroup) nameGroup.style.display = "none";
    if (document.getElementById("auth-password-group")) document.getElementById("auth-password-group").style.display = "none";
    if (document.getElementById("auth-divider")) document.getElementById("auth-divider").style.display = "none";
    if (document.getElementById("auth-google-btn")) document.getElementById("auth-google-btn").style.display = "none";
    if (passwordInput) passwordInput.required = false;
    if (toggleText) toggleText.textContent = "Remember your password? ";
    if (toggleLink) {
      toggleLink.textContent = "Back to Log In";
      toggleLink.onclick = () => setAuthMode("login");
    }
    if (emoji) emoji.textContent = "🔑";
  } else {
    if (title) title.textContent = "Welcome Back";
    if (subtitle) subtitle.textContent = "Log in to sync your progress";
    if (submitBtn) {
      submitBtn.textContent = "⚡ Log In";
      submitBtn.dataset.mode = "login";
    }
    if (nameGroup) nameGroup.style.display = "none";
    if (document.getElementById("auth-password-group")) document.getElementById("auth-password-group").style.display = "flex";
    if (document.getElementById("auth-divider")) document.getElementById("auth-divider").style.display = "flex";
    if (document.getElementById("auth-google-btn")) document.getElementById("auth-google-btn").style.display = "flex";
    if (passwordInput) passwordInput.required = true;
    if (toggleText) toggleText.textContent = "Don't have an account? ";
    if (toggleLink) {
      toggleLink.textContent = "Sign up";
      toggleLink.onclick = () => setAuthMode("signup");
    }
    if (emoji) emoji.textContent = "⚡";
  }
}

function showAuthError(message) {
  const errorEl = document.getElementById("auth-error");
  if (errorEl) {
    errorEl.textContent = message;
    errorEl.classList.add("visible");
  }
}

function clearAuthError() {
  const errorEl = document.getElementById("auth-error");
  if (errorEl) {
    errorEl.classList.remove("visible");
    errorEl.style.background = "";
    errorEl.style.borderColor = "";
    errorEl.style.color = "";
  }
}

function showAuthLoading(loading) {
  const btn = document.getElementById("auth-submit-btn");
  const googleBtn = document.getElementById("auth-google-btn");
  if (btn) btn.disabled = loading;
  if (googleBtn) googleBtn.disabled = loading;
}

function toggleUserDropdown() {
  const dropdown = document.getElementById("user-dropdown");
  if (dropdown) dropdown.classList.toggle("active");
}

function closeUserDropdown() {
  const dropdown = document.getElementById("user-dropdown");
  if (dropdown) dropdown.classList.remove("active");
}

function showSyncStatus(status) {
  const indicator = document.getElementById("sync-indicator");
  if (!indicator) return;

  if (status === "synced") {
    indicator.style.display = "inline-flex";
    indicator.innerHTML = '<span class="sync-indicator__dot"></span> Synced';
  } else if (status === "syncing") {
    indicator.style.display = "inline-flex";
    indicator.innerHTML =
      '<span class="sync-indicator__dot sync-indicator__dot--syncing"></span> Syncing…';
  } else if (status === "error") {
    indicator.style.display = "inline-flex";
    indicator.innerHTML =
      '<span class="sync-indicator__dot" style="background:#EF5350"></span> Offline';
  } else {
    indicator.style.display = "none";
  }
}

// ═══════════════════════════════════════════════════════════
// FORM HANDLER
// ═══════════════════════════════════════════════════════════

async function handleAuthSubmit(e) {
  e.preventDefault();
  clearAuthError();

  const email = document.getElementById("auth-email")?.value?.trim();
  const password = document.getElementById("auth-password")?.value;
  const name = document.getElementById("auth-name")?.value?.trim();
  const mode = document.getElementById("auth-submit-btn")?.dataset?.mode;

  if (!email) {
    showAuthError("Please enter your email.");
    return;
  }

  if (mode === "reset") {
    showAuthLoading(true);
    try {
      await db_auth.sendPasswordResetEmail(email);
      showAuthError("Password reset link sent! Check your inbox.");
      document.getElementById("auth-error").style.background = "rgba(102, 187, 106, 0.1)";
      document.getElementById("auth-error").style.borderColor = "rgba(102, 187, 106, 0.2)";
      document.getElementById("auth-error").style.color = "#66bb6a";
    } catch (err) {
      showAuthError(friendlyError(err.code));
    } finally {
      showAuthLoading(false);
    }
    return;
  }

  if (!password) {
    showAuthError("Please enter your password.");
    return;
  }

  if (password.length < 6) {
    showAuthError("Password must be at least 6 characters.");
    return;
  }

  let result;
  if (mode === "signup") {
    result = await authSignUp(email, password, name);
  } else {
    result = await authSignIn(email, password);
  }

  if (!result.success && result.error) {
    showAuthError(result.error);
  }
}

async function handleGoogleSignIn() {
  clearAuthError();
  const result = await authSignInWithGoogle();
  if (!result.success && result.error) {
    showAuthError(result.error);
  }
}

// ═══════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════

function friendlyError(code) {
  const map = {
    "auth/email-already-in-use":
      "This email is already registered. Try logging in.",
    "auth/invalid-email": "Please enter a valid email address.",
    "auth/weak-password": "Password should be at least 6 characters.",
    "auth/user-not-found": "No account found with this email.",
    "auth/wrong-password": "Incorrect password. Please try again.",
    "auth/too-many-requests": "Too many attempts. Please wait a moment.",
    "auth/network-request-failed":
      "Network error. Check your internet connection.",
    "auth/invalid-credential":
      "Invalid credentials. Please check your email and password.",
    "auth/operation-not-allowed":
      "Authentication method not enabled in Firebase Console.",
    "auth/user-disabled": "This account has been disabled.",
  };
  return map[code] || `Something went wrong (${code || 'Unknown Error'}). Please try again.`;
}

// Close dropdown when clicking outside
document.addEventListener("click", (e) => {
  const userWidget = document.getElementById("auth-user-widget");
  const dropdown = document.getElementById("user-dropdown");
  if (userWidget && dropdown && !userWidget.contains(e.target)) {
    dropdown.classList.remove("active");
  }
});

// Close modal on overlay click
document.addEventListener("click", (e) => {
  if (e.target.id === "auth-overlay") {
    closeAuthModal();
  }
});

// Close modal on Escape
document.addEventListener("keydown", (e) => {
  if (e.key === "Escape") {
    closeAuthModal();
    closeUserDropdown();
  }
});

// ── Initialize on DOM ready ──
document.addEventListener("DOMContentLoaded", () => {
  initFirebase();
});
