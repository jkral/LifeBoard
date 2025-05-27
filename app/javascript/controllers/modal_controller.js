import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = ["content", "backdrop"]
  static values = { 
    open: { type: Boolean, default: false },
    closeOnEscape: { type: Boolean, default: true },
    closeOnBackdrop: { type: Boolean, default: true }
  }

  connect() {
    // Set initial visibility
    this.element.hidden = !this.openValue
    
    // Open if needed
    if (this.openValue) {
      this.open()
    }
  }

  disconnect() {
    this.removeEventListeners()
  }

  // Open the modal
  open() {
    if (this.openValue) return
    
    this.openValue = true
    this.element.hidden = false
    document.body.style.overflow = 'hidden'
    
    this.addEventListeners()
    this.focusFirstElement()
    this.dispatch('opened')
  }

  // Close the modal
  close() {
    if (!this.openValue) return
    
    this.openValue = false
    this.element.hidden = true
    document.body.style.overflow = ''
    
    this.removeEventListeners()
    this.dispatch('closed')
  }

  // Toggle the modal
  toggle() {
    this.openValue ? this.close() : this.open()
  }

  // Handle backdrop clicks
  clickOutside(event) {
    if (!this.closeOnBackdropValue) return
    
    if (this.hasContentTarget && !this.contentTarget.contains(event.target)) {
      this.close()
    }
  }

  // Handle keyboard events
  keydown(event) {
    if (event.key === 'Escape' && this.closeOnEscapeValue) {
      this.close()
    }
  }

  // Event listener management
  addEventListeners() {
    if (this.closeOnEscapeValue) {
      this.keydownHandler = this.keydown.bind(this)
      document.addEventListener('keydown', this.keydownHandler)
    }
    
    if (this.closeOnBackdropValue) {
      this.clickHandler = this.clickOutside.bind(this)
      this.element.addEventListener('click', this.clickHandler)
    }
  }

  removeEventListeners() {
    if (this.keydownHandler) {
      document.removeEventListener('keydown', this.keydownHandler)
    }
    
    if (this.clickHandler) {
      this.element.removeEventListener('click', this.clickHandler)
    }
  }

  // Focus management
  focusFirstElement() {
    const focusable = this.element.querySelector(
      'button:not([disabled]), [href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])'
    )
    
    if (focusable) {
      focusable.focus()
    }
  }
  
  // Value changed callbacks
  openValueChanged() {
    this.element.hidden = !this.openValue
  }
}
