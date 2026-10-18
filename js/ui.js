// UI controller: DOM updates and view switching.
// Milestone 1: switching between the game view and the about view.

const views = {};

export function initUI() {
  views.game = document.getElementById('game-view');
  views.about = document.getElementById('about-view');
}

// Show one view and hide the other, without reloading the page.
export function showView(name) {
  for (const [viewName, element] of Object.entries(views)) {
    element.hidden = viewName !== name;
  }
  window.scrollTo(0, 0);
}
