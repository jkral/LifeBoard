import { Controller } from "@hotwired/stimulus"

// Handles flash notifications with auto-dismiss and manual close
export default class extends Controller {
  static values = { 
    delay: { type: Number, default: 5000 },
    removeDelay: { type: Number, default: 300 }
  }

  connect() {
    // Auto-dismiss if delay is set
    if (this.delayValue > 0) {
      this.autoDismissTimeout = setTimeout(() => {
        this.dismiss()
      }, this.delayValue)
    }

    // Listen for custom flash events
    this.flashShowHandler = this.handleFlashShow.bind(this)
    window.addEventListener('flash:show', this.flashShowHandler)
    
    // Add enter animation
    requestAnimationFrame(() => {
      this.element.classList.remove('opacity-0', 'translate-x-8')
      this.element.classList.add('opacity-100', 'translate-x-0')
    })
  }

  disconnect() {
    if (this.autoDismissTimeout) {
      clearTimeout(this.autoDismissTimeout)
    }
    window.removeEventListener('flash:show', this.flashShowHandler)
  }

  close() {
    this.dismiss()
  }

  dismiss() {
    // Clear auto-dismiss timeout
    if (this.autoDismissTimeout) {
      clearTimeout(this.autoDismissTimeout)
    }

    // Add exit animation
    this.element.classList.remove('opacity-100', 'translate-x-0')
    this.element.classList.add('opacity-0', 'translate-x-8')
    
    // Remove element after animation
    setTimeout(() => {
      this.element.remove()
    }, this.removeDelayValue)
  }

  // Handle custom flash events from other controllers
  handleFlashShow(event) {
    const { message, type } = event.detail
    // Map types to Tailwind classes and icons
    const alertStyles = {
      success: {
        bg: 'bg-green-50',
        border: 'border-green-400',
        text: 'text-green-800',
        icon: 'text-green-400',
        iconPath: 'M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z'
      },
      warning: {
        bg: 'bg-yellow-50',
        border: 'border-yellow-400',
        text: 'text-yellow-800',
        icon: 'text-yellow-400',
        iconPath: 'M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z'
      },
      error: {
        bg: 'bg-red-50',
        border: 'border-red-400',
        text: 'text-red-800',
        icon: 'text-red-400',
        iconPath: 'M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z'
      }
    }
    const style = alertStyles[type] || alertStyles.success

    // Create notification element
    const notification = document.createElement('div')
    notification.className = `${style.bg} border-l-4 ${style.border} p-4 mb-4 rounded-md shadow-sm transform transition-all duration-300 ease-in-out opacity-0 translate-x-8 flex items-center`;
    notification.setAttribute('data-controller', 'notification')
    notification.setAttribute('data-notification-delay-value', this.delayValue)
    notification.setAttribute('data-notification-remove-delay-value', this.removeDelayValue)

    notification.innerHTML = `
      <div class="flex-shrink-0">
        <svg class="h-5 w-5 ${style.icon}" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="${style.iconPath}" clip-rule="evenodd" />
        </svg>
      </div>
      <div class="ml-3">
        <p class="text-sm font-medium ${style.text}">${message}</p>
      </div>
      <div class="ml-auto pl-3">
        <div class="-mx-1.5 -my-1.5">
          <button type="button" class="inline-flex rounded-md p-1.5 ${style.icon} hover:bg-opacity-20 hover:bg-black focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-green-50 focus:ring-green-600" data-action="click->notification#dismiss">
            <span class="sr-only">Dismiss</span>
            <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
      </div>
    `

    // Append to #flash container
    const flashContainer = document.getElementById('flash')
    if (flashContainer) {
      flashContainer.appendChild(notification)
      // Stimulus will pick up the controller on the new element
      // Add enter animation
      requestAnimationFrame(() => {
        notification.classList.remove('opacity-0', 'translate-x-8')
        notification.classList.add('opacity-100', 'translate-x-0')
      })
      // Auto-dismiss
      setTimeout(() => {
        if (notification.parentNode) {
          notification.classList.remove('opacity-100', 'translate-x-0')
          notification.classList.add('opacity-0', 'translate-x-8')
          setTimeout(() => notification.remove(), this.removeDelayValue)
        }
      }, this.delayValue)
    }
  }
}
