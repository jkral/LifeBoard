import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submit", "title", "description"]
  
  connect() {
    console.log("[GoalForm] Controller connected")
    this.submitTarget.disabled = false
  }
  
  // Handle form submission
  submit(event) {
    event.preventDefault()
    
    // Disable the submit button to prevent double submission
    this.submitTarget.disabled = true
    this.submitTarget.classList.add('opacity-50', 'cursor-not-allowed')
    
    // Submit the form via Turbo
    this.element.requestSubmit()
  }
  
  // Handle form submission response
  handleSubmitEnd(event) {
    const response = event.detail
    const form = this.element
    
    console.log("[GoalForm] Submit end", response)
    
    // Re-enable the submit button
    this.submitTarget.disabled = false
    this.submitTarget.classList.remove('opacity-50', 'cursor-not-allowed')
    
    // Check if the response indicates success
    if (response.success || response.fetchResponse?.succeeded) {
      // Reset the form
      form.reset()
      
      // Close the modal
      this.closeModal()
      
      // Focus back on the trigger button if needed
      const trigger = document.querySelector('[data-action~="modal#open"]')
      trigger?.focus()
    } else {
      // Handle validation errors
      this.handleErrors(response.fetchResponse?.response)
    }
  }
}
