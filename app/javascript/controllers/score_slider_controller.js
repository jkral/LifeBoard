import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="score-slider"
export default class extends Controller {
  static values = {
    subcategoryId: Number
  }

  connect() {
    // Initialize any necessary state
  }

  updateScore(event) {
    const score = event.target.value
    const subcategoryId = this.subcategoryIdValue
    
    // Update the displayed score next to the slider
    const scoreDisplay = this.element.nextElementSibling
    if (scoreDisplay) {
      scoreDisplay.textContent = score
    }
    
    // Send the update to the server
    this.updateSubcategoryScore(subcategoryId, score)
  }
  
  async updateSubcategoryScore(subcategoryId, score) {
    const url = `/categories/1/subcategories/${subcategoryId}` // Update with dynamic category ID if needed
    const token = document.querySelector('meta[name="csrf-token"]').content
    
    try {
      const response = await fetch(url, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': token,
          'Accept': 'text/vnd.turbo-stream.html, text/html, application/xhtml+xml',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({ 
          subcategory: { 
            score: parseFloat(score) 
          } 
        })
      })
      
      if (!response.ok) {
        throw new Error('Network response was not ok')
      }
      
      // Handle the response, maybe update the UI or show a success message
      console.log('Score updated successfully')
      
      // If using Turbo, you might want to handle the response
      if (response.redirected) {
        window.location.href = response.url
      }
      
    } catch (error) {
      console.error('Error updating score:', error)
      // Show error message to user
    }
  }
}
