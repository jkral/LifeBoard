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
    // Find the score display in the new design structure
    const parentItem = this.element.closest('.subcategory-item')
    if (parentItem) {
      const scoreDisplay = parentItem.querySelector('.subcategory-header span')
      if (scoreDisplay) {
        // Ensure we're working with a number and format to 1 decimal place
        const formattedScore = parseFloat(score).toFixed(1)
        scoreDisplay.textContent = formattedScore
        // Also update the input value to ensure consistency
        event.target.value = parseFloat(score).toFixed(1)
      }
    }
    
    // Send the update to the server
    this.updateSubcategoryScore(subcategoryId, score)
  }
  
  async updateSubcategoryScore(subcategoryId, score) {
    // Get the category ID from the URL path
    const pathParts = window.location.pathname.split('/')
    const categoryId = pathParts[pathParts.indexOf('categories') + 1]
    
    const url = `/categories/${categoryId}/subcategories/${subcategoryId}`
    const token = document.querySelector('meta[name="csrf-token"]').content
    
    try {
      const response = await fetch(url, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': token,
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({ 
          subcategory: { 
            score: parseFloat(score).toFixed(1) // Ensure consistent decimal places
          } 
        })
      })

      if (!response.ok) {
        throw new Error('Network response was not ok')
      }
      
      // Handle the response and update the UI
      const responseData = await response.json()
      
      // Update the category score display
      if (responseData.category_score) {
        const scoreDisplay = document.querySelector('.score-display')
        if (scoreDisplay) {
          scoreDisplay.textContent = parseFloat(responseData.category_score).toFixed(1)
        }
      }
      
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
