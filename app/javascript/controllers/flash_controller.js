import BaseController from "./base_controller"

// Handles flash message dismiss functionality
export default class extends BaseController {
  static values = { 
    autoDismiss: { type: Number, default: 5000 }
  }
  
  connect() {
    // Auto-dismiss if configured
    if (this.autoDismissValue > 0) {
      this.autoDismissTimeout = setTimeout(() => {
        this.dismiss()
      }, this.autoDismissValue)
    }
  }
  
  disconnect() {
    if (this.autoDismissTimeout) {
      clearTimeout(this.autoDismissTimeout)
    }
  }
  
  // Dismisses the flash message when the dismiss button is clicked
  dismiss() {
    if (this.autoDismissTimeout) {
      clearTimeout(this.autoDismissTimeout)
    }
    
    // Fade out animation
    this.element.classList.add('opacity-0', 'translate-x-8')
    
    // Remove after animation completes
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
