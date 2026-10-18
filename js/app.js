// Entry point: initializes modules and wires UI events.
// Service Worker registration is added in Milestone 5.

import { initUI, showView } from './ui.js';

initUI();

document.getElementById('about-btn').addEventListener('click', () => {
  showView('about');
});

document.getElementById('back-btn').addEventListener('click', () => {
  showView('game');
});
