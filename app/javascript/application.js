// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import 'flowbite'
import 'flowbite-datepicker'
import "./controllers/goals_board_controller"

// Initialize Alpine.js
document.addEventListener('DOMContentLoaded', () => {
  // Auto-hide flash messages after 5 seconds
  const flashMessages = document.querySelectorAll('[data-controller="flash"]');
  flashMessages.forEach(flash => {
    setTimeout(() => {
      flash.remove();
    }, 5000);
  });
});

// Make Alpine.js work with Turbo
document.addEventListener('turbo:load', () => {
  // Re-initialize Flowbite components after Turbo navigation
  if (window.Flowbite) {
    window.Flowbite.init();
  }
});
