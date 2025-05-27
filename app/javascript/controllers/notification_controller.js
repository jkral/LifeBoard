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
    // This would need to create a new notification element
    // For now, just log it - in production, you'd create the element
    console.warn('Flash show event received but element creation not implemented', { message, type })
  }
}
