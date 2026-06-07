/* ═══════════════════════════════════════════════════════════
   DeutschBlitz — Website Interactivity
   Animations, accordions, flashcards, phrase filtering
   ═══════════════════════════════════════════════════════════ */

// ── Wait for DOM ──
document.addEventListener('DOMContentLoaded', () => {
  initNavbar();
  initScrollReveal();
  initCounters();
  initPhrases();
  initTypingEffect();
});

/* ═══════════════════════════════════════════════════════════
   NAVBAR — Scroll effect + Mobile menu
   ═══════════════════════════════════════════════════════════ */

function initNavbar() {
  const navbar = document.getElementById('navbar');
  const hamburger = document.getElementById('hamburger-btn');
  const mobileNav = document.getElementById('mobile-nav');

  // Scroll effect
  let lastScroll = 0;
  window.addEventListener('scroll', () => {
    const scrollY = window.scrollY;
    if (scrollY > 60) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }
    lastScroll = scrollY;
  }, { passive: true });

  // Active link highlighting
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('.navbar__link');

  window.addEventListener('scroll', () => {
    const scrollPos = window.scrollY + 200;
    sections.forEach(section => {
      const top = section.offsetTop;
      const height = section.offsetHeight;
      const id = section.getAttribute('id');

      if (scrollPos >= top && scrollPos < top + height) {
        navLinks.forEach(link => {
          link.classList.remove('active');
          if (link.getAttribute('href') === `#${id}`) {
            link.classList.add('active');
          }
        });
      }
    });
  }, { passive: true });

  // Mobile hamburger
  hamburger.addEventListener('click', () => {
    hamburger.classList.toggle('open');
    mobileNav.classList.toggle('open');
    document.body.style.overflow = mobileNav.classList.contains('open') ? 'hidden' : '';
  });

  // Close mobile nav on link click
  document.querySelectorAll('.mobile-nav__link').forEach(link => {
    link.addEventListener('click', () => {
      hamburger.classList.remove('open');
      mobileNav.classList.remove('open');
      document.body.style.overflow = '';
    });
  });
}

/* ═══════════════════════════════════════════════════════════
   SCROLL REVEAL — IntersectionObserver
   ═══════════════════════════════════════════════════════════ */

function initScrollReveal() {
  const revealElements = document.querySelectorAll('.reveal, .reveal--left, .reveal--right, .reveal--scale, .stagger');

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        // Don't unobserve — let them stay visible
      }
    });
  }, {
    threshold: 0.15,
    rootMargin: '0px 0px -50px 0px'
  });

  revealElements.forEach(el => observer.observe(el));
}

/* ═══════════════════════════════════════════════════════════
   ANIMATED COUNTERS
   ═══════════════════════════════════════════════════════════ */

function initCounters() {
  const counters = document.querySelectorAll('[data-count]');

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        animateCounter(entry.target);
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.5 });

  counters.forEach(counter => observer.observe(counter));
}

function animateCounter(element) {
  const target = parseInt(element.getAttribute('data-count'), 10);
  const duration = 2000;
  const startTime = performance.now();

  function easeOutCubic(t) {
    return 1 - Math.pow(1 - t, 3);
  }

  function update(currentTime) {
    const elapsed = currentTime - startTime;
    const progress = Math.min(elapsed / duration, 1);
    const easedProgress = easeOutCubic(progress);
    const currentValue = Math.round(easedProgress * target);

    element.textContent = target >= 100 ? `${currentValue}+` : currentValue;

    if (progress < 1) {
      requestAnimationFrame(update);
    }
  }

  requestAnimationFrame(update);
}

/* ═══════════════════════════════════════════════════════════
   ACCORDION
   ═══════════════════════════════════════════════════════════ */

function toggleAccordion(id) {
  const accordion = document.getElementById(id);
  const isOpen = accordion.classList.contains('open');

  // Close all others (optional — for single-open behavior)
  // document.querySelectorAll('.accordion.open').forEach(a => a.classList.remove('open'));

  accordion.classList.toggle('open');
}

/* ═══════════════════════════════════════════════════════════
   FLASHCARD WIDGET
   ═══════════════════════════════════════════════════════════ */

const flashcardData = [
  { article: 'der', word: 'Tisch', translation: 'Table', example: '"Der Tisch steht am Fenster."', articleClass: 'der' },
  { article: 'die', word: 'Lampe', translation: 'Lamp', example: '"Die Lampe ist an."', articleClass: 'die' },
  { article: 'das', word: 'Brot', translation: 'Bread', example: '"Ich esse das Brot zum Frühstück."', articleClass: 'das' },
  { article: 'der', word: 'Kaffee', translation: 'Coffee', example: '"Der Kaffee ist heiß."', articleClass: 'der' },
  { article: 'die', word: 'Wohnung', translation: 'Apartment', example: '"Die Wohnung ist groß."', articleClass: 'die' },
  { article: 'das', word: 'Kind', translation: 'Child', example: '"Das Kind spielt im Park."', articleClass: 'das' },
  { article: 'die', word: 'Straßenbahn', translation: 'Tram', example: '"Die Straßenbahn fährt zum Hauptbahnhof."', articleClass: 'die' },
  { article: 'der', word: 'Fahrschein', translation: 'Ticket', example: '"Ich brauche einen Fahrschein."', articleClass: 'der' },
  { article: 'die', word: 'Milch', translation: 'Milk', example: '"Die Milch ist frisch."', articleClass: 'die' },
  { article: 'das', word: 'Zimmer', translation: 'Room', example: '"Das Zimmer ist hell."', articleClass: 'das' },
];

let currentFlashcardIndex = 0;

function updateFlashcard() {
  const card = flashcardData[currentFlashcardIndex];
  const flashcardEl = document.getElementById('flashcard');

  // Remove flip
  flashcardEl.classList.remove('flipped');

  // Update front
  const articleEl = document.getElementById('fc-article');
  articleEl.textContent = card.article;
  articleEl.className = `flashcard__article flashcard__article--${card.articleClass}`;

  document.getElementById('fc-word').textContent = card.word;

  // Update back
  document.getElementById('fc-translation').textContent = card.translation;
  document.getElementById('fc-example').textContent = card.example;

  // Update counter
  document.getElementById('fc-counter').textContent = `${currentFlashcardIndex + 1} / ${flashcardData.length}`;
}

function toggleFlashcard() {
  document.getElementById('flashcard').classList.toggle('flipped');
}

function nextFlashcard() {
  currentFlashcardIndex = (currentFlashcardIndex + 1) % flashcardData.length;
  updateFlashcard();
  if (typeof addXP === 'function') addXP(2); // Gamification integration
}

function prevFlashcard() {
  currentFlashcardIndex = (currentFlashcardIndex - 1 + flashcardData.length) % flashcardData.length;
  updateFlashcard();
}

/* ═══════════════════════════════════════════════════════════
   PHRASES DATA & FILTERING
   ═══════════════════════════════════════════════════════════ */

const phrasesData = {
  greetings: [
    { german: 'Hallo!', english: 'Hello!', context: 'Informal greeting' },
    { german: 'Guten Morgen!', english: 'Good morning!', context: 'Until about 11 AM' },
    { german: 'Guten Tag!', english: 'Good day / Hello!', context: 'Formal, anytime during the day' },
    { german: 'Guten Abend!', english: 'Good evening!', context: 'After about 6 PM' },
    { german: 'Gute Nacht!', english: 'Good night!', context: 'When saying goodbye at night / bedtime' },
    { german: 'Wie geht es Ihnen?', english: 'How are you? (formal)', context: 'With strangers, professors' },
    { german: 'Wie geht\'s?', english: 'How\'s it going?', context: 'Informal, with friends' },
    { german: 'Mir geht es gut, danke.', english: 'I\'m fine, thank you.', context: 'Standard response' },
    { german: 'Ich heiße…', english: 'My name is…', context: 'Introducing yourself' },
    { german: 'Woher kommen Sie?', english: 'Where are you from? (formal)', context: 'Asking someone\'s origin' },
    { german: 'Ich komme aus…', english: 'I come from…', context: 'Stating your origin' },
    { german: 'Freut mich!', english: 'Pleased to meet you!', context: 'When meeting someone for the first time' },
    { german: 'Tschüss!', english: 'Bye!', context: 'Informal goodbye' },
    { german: 'Auf Wiedersehen!', english: 'Goodbye! (formal)', context: 'Formal goodbye' },
    { german: 'Bis morgen!', english: 'See you tomorrow!', context: 'Casual farewell' },
  ],

  food: [
    { german: 'Ich hätte gerne…', english: 'I would like…', context: 'Polite way to order' },
    { german: 'Die Speisekarte, bitte.', english: 'The menu, please.', context: 'At a restaurant' },
    { german: 'Was empfehlen Sie?', english: 'What do you recommend?', context: 'Asking the waiter' },
    { german: 'Ich bin Vegetarier/Vegetarierin.', english: 'I am vegetarian. (m/f)', context: 'Dietary information' },
    { german: 'Guten Appetit!', english: 'Enjoy your meal!', context: 'Said before eating' },
    { german: 'Das schmeckt gut!', english: 'That tastes good!', context: 'Complimenting food' },
    { german: 'Die Rechnung, bitte.', english: 'The bill, please.', context: 'At a restaurant' },
    { german: 'Zusammen oder getrennt?', english: 'Together or separate?', context: 'Splitting the bill' },
    { german: 'Ein Wasser, bitte.', english: 'A water, please.', context: 'Ordering drinks' },
    { german: 'Mit oder ohne Kohlensäure?', english: 'Sparkling or still?', context: 'German water question' },
    { german: 'Noch ein Bier, bitte.', english: 'Another beer, please.', context: 'At a bar/restaurant' },
    { german: 'Ich nehme das Tagesgericht.', english: 'I\'ll take the daily special.', context: 'At the Mensa/restaurant' },
    { german: 'Haben Sie etwas ohne Gluten?', english: 'Do you have something gluten-free?', context: 'Dietary needs' },
  ],

  directions: [
    { german: 'Entschuldigung, wo ist…?', english: 'Excuse me, where is…?', context: 'Asking for a location' },
    { german: 'Wie komme ich zum Bahnhof?', english: 'How do I get to the train station?', context: 'Asking for directions' },
    { german: 'Gehen Sie geradeaus.', english: 'Go straight ahead.', context: 'Giving directions' },
    { german: 'Biegen Sie links/rechts ab.', english: 'Turn left/right.', context: 'At an intersection' },
    { german: 'Es ist in der Nähe.', english: 'It is nearby.', context: 'Indicating proximity' },
    { german: 'Wo ist die nächste Haltestelle?', english: 'Where is the nearest stop?', context: 'For bus/tram' },
    { german: 'Ich suche die Universität.', english: 'I\'m looking for the university.', context: 'Finding a place' },
    { german: 'Ist es weit von hier?', english: 'Is it far from here?', context: 'Asking about distance' },
    { german: 'Können Sie mir helfen?', english: 'Can you help me?', context: 'Polite request' },
    { german: 'Welche Linie fährt zum…?', english: 'Which line goes to…?', context: 'Public transport' },
    { german: 'Ich möchte ein Ticket kaufen.', english: 'I\'d like to buy a ticket.', context: 'At the ticket machine' },
    { german: 'Die erste/zweite Straße links.', english: 'The first/second street on the left.', context: 'Giving directions' },
  ],

  shopping: [
    { german: 'Was kostet das?', english: 'How much does that cost?', context: 'Asking the price' },
    { german: 'Wie viel kostet das?', english: 'How much is that?', context: 'Alternative price question' },
    { german: 'Ich möchte das kaufen.', english: 'I want to buy that.', context: 'At a shop' },
    { german: 'Haben Sie das in einer anderen Größe?', english: 'Do you have that in another size?', context: 'Clothing shopping' },
    { german: 'Kann ich mit Karte zahlen?', english: 'Can I pay by card?', context: 'At checkout' },
    { german: 'Nur Bargeld, bitte.', english: 'Cash only, please.', context: 'Many German shops!' },
    { german: 'Wo finde ich…?', english: 'Where do I find…?', context: 'In a supermarket' },
    { german: 'Ich brauche eine Tüte.', english: 'I need a bag.', context: 'At checkout (bags cost money!)' },
    { german: 'Das ist zu teuer.', english: 'That is too expensive.', context: 'Reacting to price' },
    { german: 'Gibt es einen Rabatt?', english: 'Is there a discount?', context: 'Asking for deals' },
  ],

  emergency: [
    { german: 'Hilfe!', english: 'Help!', context: 'Emergency call' },
    { german: 'Rufen Sie die Polizei!', english: 'Call the police!', context: 'Emergency: 110' },
    { german: 'Rufen Sie einen Krankenwagen!', english: 'Call an ambulance!', context: 'Emergency: 112' },
    { german: 'Ich brauche einen Arzt.', english: 'I need a doctor.', context: 'Medical situation' },
    { german: 'Wo ist das Krankenhaus?', english: 'Where is the hospital?', context: 'Finding medical help' },
    { german: 'Ich habe mich verlaufen.', english: 'I am lost.', context: 'When you\'re lost' },
    { german: 'Ich verstehe nicht.', english: 'I don\'t understand.', context: 'Communication difficulty' },
    { german: 'Sprechen Sie Englisch?', english: 'Do you speak English?', context: 'Language barrier' },
    { german: 'Können Sie das wiederholen?', english: 'Can you repeat that?', context: 'When you didn\'t catch something' },
    { german: 'Es tut mir leid.', english: 'I\'m sorry.', context: 'Apologizing' },
  ],

  university: [
    { german: 'Wann beginnt die Vorlesung?', english: 'When does the lecture start?', context: 'University schedule' },
    { german: 'Wo ist der Hörsaal?', english: 'Where is the lecture hall?', context: 'Finding your classroom' },
    { german: 'Ich studiere an der TU Freiberg.', english: 'I study at TU Freiberg.', context: 'Introducing your university' },
    { german: 'Was studierst du?', english: 'What do you study?', context: 'Common student question' },
    { german: 'Ich studiere Ingenieurwesen.', english: 'I study engineering.', context: 'Stating your major' },
    { german: 'Haben Sie die Hausaufgaben?', english: 'Do you have the homework?', context: 'Asking a classmate' },
    { german: 'Ich habe eine Frage.', english: 'I have a question.', context: 'In class' },
    { german: 'Können Sie das erklären?', english: 'Can you explain that?', context: 'To the professor' },
    { german: 'Wo ist die Bibliothek?', english: 'Where is the library?', context: 'On campus' },
    { german: 'Die Prüfung ist am Montag.', english: 'The exam is on Monday.', context: 'Exam schedule' },
    { german: 'Ich brauche eine Verlängerung.', english: 'I need an extension.', context: 'For assignments' },
    { german: 'Treffen wir uns in der Mensa?', english: 'Shall we meet at the cafeteria?', context: 'Meeting friends for lunch' },
  ],
};

let currentCategory = 'greetings';

function initPhrases() {
  filterPhrases('greetings');
}

function filterPhrases(category) {
  currentCategory = category;

  // Update tabs
  document.querySelectorAll('.phrases__tab').forEach(tab => {
    tab.classList.toggle('active', tab.getAttribute('data-category') === category);
  });

  // Render phrases
  const grid = document.getElementById('phrases-grid');
  const phrases = phrasesData[category] || [];

  grid.innerHTML = '';

  phrases.forEach((phrase, index) => {
    const card = document.createElement('div');
    card.className = 'phrase-card';
    card.style.opacity = '0';
    card.style.transform = 'translateY(20px)';
    card.innerHTML = `
      <div style="display: flex; align-items: center; justify-content: space-between;">
        <div class="phrase-card__german">${phrase.german}</div>
        <button class="audio-btn" onclick="playAudio(event, '${phrase.german.replace(/'/g, "\\'")}')">🔊</button>
      </div>
      <div class="phrase-card__english">${phrase.english}</div>
      ${phrase.context ? `<div class="phrase-card__context">💡 ${phrase.context}</div>` : ''}
    `;
    grid.appendChild(card);

    // Staggered animation
    requestAnimationFrame(() => {
      setTimeout(() => {
        card.style.transition = 'opacity 0.4s ease-out, transform 0.4s ease-out';
        card.style.opacity = '1';
        card.style.transform = 'translateY(0)';
      }, index * 50);
    });
  });
}

/* ═══════════════════════════════════════════════════════════
   HERO TYPING EFFECT
   ═══════════════════════════════════════════════════════════ */

function initTypingEffect() {
  const phrases = [
    'Blitz Style ⚡',
    'der, die, das 🎯',
    'Satz für Satz 🧩',
    'mit Vokabeln 🃏',
    'Level für Level 🏆',
  ];

  const typedEl = document.getElementById('hero-typed');
  let phraseIndex = 0;
  let charIndex = 0;
  let isDeleting = false;
  let currentPhrase = phrases[0];

  // Start with first phrase already displayed
  typedEl.textContent = currentPhrase;

  // Wait a bit before starting the loop
  setTimeout(() => {
    isDeleting = true;
    typeLoop();
  }, 3000);

  function typeLoop() {
    currentPhrase = phrases[phraseIndex];

    if (isDeleting) {
      charIndex--;
      typedEl.textContent = currentPhrase.substring(0, charIndex);

      if (charIndex === 0) {
        isDeleting = false;
        phraseIndex = (phraseIndex + 1) % phrases.length;
        setTimeout(typeLoop, 400);
        return;
      }
      setTimeout(typeLoop, 40);
    } else {
      charIndex++;
      typedEl.textContent = currentPhrase.substring(0, charIndex);

      if (charIndex === currentPhrase.length) {
        isDeleting = true;
        setTimeout(typeLoop, 2500);
        return;
      }
      setTimeout(typeLoop, 80);
    }
  }
}

/* ═══════════════════════════════════════════════════════════
   SMOOTH SCROLL for CTA links
   ═══════════════════════════════════════════════════════════ */

// Global function to launch the Flutter App iframe
window.launchApp = function() {
  const container = document.getElementById('app-container');
  if (container) {
    container.outerHTML = '<iframe src="../build/web/index.html?v=2" class="app-preview__frame" id="app-iframe"></iframe>';
  }
};

window.playAudio = function(event, text) {
  if (event) {
    event.stopPropagation();
  }
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = 'de-DE';
  window.speechSynthesis.speak(utterance);
};

document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', function (e) {
    const targetId = this.getAttribute('href');
    if (targetId === '#') return;

    const targetEl = document.querySelector(targetId);
    if (targetEl) {
      e.preventDefault();
      window.scrollTo({
        top: targetEl.offsetTop - 80,
        behavior: 'smooth'
      });

      // If clicking a CTA pointing to app-preview, auto-trigger launch after a short delay
      if (targetId === '#app-preview') {
        setTimeout(window.launchApp, 500);
      }
    }
  });
});

/* ═══════════════════════════════════════════════════════════
   GAMIFICATION SYSTEM
   ═══════════════════════════════════════════════════════════ */
let xp = 0;
let level = 1;
let streak = 0;

function addXP(amount) {
  xp += amount;
  streak++;
  
  let xpNeeded = level * 100;
  if (xp >= xpNeeded) {
    xp -= xpNeeded;
    level++;
    
    const widget = document.getElementById('gamification-widget');
    if (widget) {
      widget.classList.add('level-up');
      setTimeout(() => widget.classList.remove('level-up'), 1000);
    }
  }
  
  updateGamificationUI();
}

function updateGamificationUI() {
  const levelEl = document.getElementById('gw-level');
  if (!levelEl) return;
  
  levelEl.textContent = `Lv ${level}`;
  document.getElementById('gw-streak').textContent = streak;
  document.getElementById('gw-xp-current').textContent = xp;
  document.getElementById('gw-xp-next').textContent = level * 100;
  
  const percentage = (xp / (level * 100)) * 100;
  document.getElementById('gw-xp-fill').style.width = `${percentage}%`;
}

/* ═══════════════════════════════════════════════════════════
   ARTICLE TRAINER
   ═══════════════════════════════════════════════════════════ */
const atWords = [
  { word: "Apfel", article: "der" },
  { word: "Auto", article: "das" },
  { word: "Frau", article: "die" },
  { word: "Hund", article: "der" },
  { word: "Buch", article: "das" },
  { word: "Katze", article: "die" },
  { word: "Mann", article: "der" },
  { word: "Kind", article: "das" },
  { word: "Sonne", article: "die" }
];
let atCurrentIndex = 0;

function loadNextArticleWord() {
  const wordObj = atWords[atCurrentIndex];
  const wordEl = document.getElementById('at-word');
  if (!wordEl) return;
  
  wordEl.textContent = wordObj.word;
  document.getElementById('at-word-box').className = 'article-trainer__word-box';
}

window.checkArticle = function(selectedArticle) {
  const correctArticle = atWords[atCurrentIndex].article;
  const box = document.getElementById('at-word-box');
  if (!box) return;
  
  if (selectedArticle === correctArticle) {
    box.classList.add('at-success');
    addXP(10);
    atCurrentIndex = (atCurrentIndex + 1) % atWords.length;
    setTimeout(loadNextArticleWord, 800);
  } else {
    box.classList.add('at-error');
    streak = 0;
    updateGamificationUI();
    setTimeout(() => box.className = 'article-trainer__word-box', 800);
  }
};

/* ═══════════════════════════════════════════════════════════
   SENTENCE BUILDER
   ═══════════════════════════════════════════════════════════ */
const sentences = [
  { english: "I drink a coffee.", words: ["Ich", "trinke", "einen", "Kaffee", "."] },
  { english: "The dog plays in the garden.", words: ["Der", "Hund", "spielt", "im", "Garten", "."] },
  { english: "She learns German.", words: ["Sie", "lernt", "Deutsch", "."] },
  { english: "We go to the cinema.", words: ["Wir", "gehen", "ins", "Kino", "."] }
];
let sbCurrentIndex = 0;
let currentSentenceObj = null;
let selectedWords = [];
let shuffledBank = [];

function shuffleArray(array) {
  const arr = [...array];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

function initSentence() {
  const dropzone = document.getElementById('sb-dropzone');
  if (!dropzone) return;
  
  currentSentenceObj = sentences[sbCurrentIndex];
  selectedWords = [];
  shuffledBank = shuffleArray(currentSentenceObj.words);
  
  document.getElementById('sb-english').textContent = currentSentenceObj.english;
  renderSentenceUI();
}

function renderSentenceUI() {
  const dropzone = document.getElementById('sb-dropzone');
  const wordbank = document.getElementById('sb-wordbank');
  if (!dropzone || !wordbank) return;
  
  dropzone.innerHTML = '';
  wordbank.innerHTML = '';
  
  selectedWords.forEach((word, idx) => {
    const el = document.createElement('div');
    el.className = 'sb-word';
    el.textContent = word;
    el.onclick = () => removeWord(idx);
    dropzone.appendChild(el);
  });
  
  shuffledBank.forEach((word, idx) => {
    const isUsed = selectedWords.includes(word);
    const el = document.createElement('div');
    el.className = 'sb-word' + (isUsed ? ' used' : '');
    el.textContent = word;
    if (!isUsed) {
      el.onclick = () => addWord(word);
    }
    wordbank.appendChild(el);
  });
}

function addWord(word) {
  if (!selectedWords.includes(word)) {
    selectedWords.push(word);
    renderSentenceUI();
  }
}

function removeWord(index) {
  selectedWords.splice(index, 1);
  renderSentenceUI();
}

window.resetSentence = function() {
  selectedWords = [];
  renderSentenceUI();
};

window.checkSentence = function() {
  const userSentence = selectedWords.join(' ');
  const correctSentence = currentSentenceObj.words.join(' ');
  const dropzone = document.getElementById('sb-dropzone');
  if (!dropzone) return;
  
  if (userSentence === correctSentence) {
    dropzone.style.borderColor = 'var(--das-green)';
    dropzone.style.backgroundColor = 'rgba(102, 187, 106, 0.1)';
    addXP(20);
    
    setTimeout(() => {
      sbCurrentIndex = (sbCurrentIndex + 1) % sentences.length;
      dropzone.style.borderColor = 'var(--glass-border)';
      dropzone.style.backgroundColor = 'var(--bg-primary)';
      initSentence();
    }, 1500);
  } else {
    dropzone.style.borderColor = 'var(--die-pink)';
    dropzone.style.backgroundColor = 'rgba(239, 83, 80, 0.1)';
    streak = 0;
    updateGamificationUI();
    
    setTimeout(() => {
      dropzone.style.borderColor = 'var(--glass-border)';
      dropzone.style.backgroundColor = 'var(--bg-primary)';
    }, 800);
  }
};

// Initialize interactive widgets
setTimeout(() => {
  updateGamificationUI();
  loadNextArticleWord();
  initSentence();
}, 100);
