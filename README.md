# ⚡ DeutschBlitz — German A1 Learning Platform

A fully web-based, gamified learning platform to master German A1. Built with vanilla HTML, CSS, and JavaScript — no frameworks, no dependencies, no build step needed.

## 🚀 Getting Started

Simply open any HTML file in your browser:

```
website/index.html        → Homepage & hub
website/article-trainer.html  → der/die/das training game
website/verb-trainer.html     → Verb conjugation quiz
website/sentence-builder.html → Word order practice
website/vocab-quiz.html       → 500+ vocabulary flashcards
website/grammar.html          → Complete A1 grammar reference
```

Or serve locally with any static server:
```bash
cd website
npx serve .
```

## 📚 Features

| Feature | Description |
|---------|-------------|
| 🇩🇪 **Article Trainer** | 60+ nouns, color-coded der/die/das buttons, streaks, XP |
| 💬 **Verb Trainer** | 20 A1 verbs, conjugation quiz with multiple choice |
| 🧩 **Sentence Builder** | Arrange words in correct German V2 word order |
| 📚 **Vocabulary Quiz** | 500+ words across 11 themes with spaced repetition |
| 📖 **Grammar Reference** | Complete A1 grammar with audio and interactive tables |
| 💬 **Essential Phrases** | 70+ phrases in 6 categories with native audio |
| 🎤 **Pronunciation** | Umlauts, tricky consonants, clickable audio examples |
| 🌍 **Culture Tips** | Du vs. Sie, Pünktlichkeit, Mülltrennung |
| 🏆 **Gamification** | XP, levels, streaks — all saved to localStorage |

## 🎨 Design

- Dark glassmorphism aesthetic
- Responsive mobile-first layout
- Google Fonts (Inter + Outfit)
- Smooth animations and micro-interactions
- Web Speech API for German pronunciation

## 📁 Project Structure

```
├── website/
│   ├── index.html              # Homepage
│   ├── index.css               # Design system & styles
│   ├── app.js                  # Homepage interactivity
│   ├── article-trainer.html    # Article training game
│   ├── verb-trainer.html       # Verb conjugation game
│   ├── sentence-builder.html   # Sentence ordering game
│   ├── vocab-quiz.html         # Vocabulary flashcards
│   └── grammar.html            # Grammar reference
├── assets/
│   ├── fonts/
│   └── images/
├── README.md
└── .gitignore
```

## 🛠️ Tech Stack

- **HTML5** — Semantic structure
- **CSS3** — Custom properties, glassmorphism, animations
- **Vanilla JavaScript** — No frameworks or dependencies
- **Web Speech API** — German text-to-speech
- **localStorage** — Progress persistence

---

Built for language learners. © 2026 DeutschBlitz.
