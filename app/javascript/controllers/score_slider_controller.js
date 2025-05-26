import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="score-slider"
export default class extends Controller {
  static values = {
    subcategoryId: Number
  }

  connect() {
    // Initialize any necessary state
    console.log('Score slider controller connected', this.element)
    console.log('Subcategory ID:', this.subcategoryIdValue)
  }

  updateScore(event) {
    console.log('updateScore called', event.type)
    const score = event.target.value
    const subcategoryId = this.subcategoryIdValue
    console.log('Score:', score, 'Subcategory ID:', subcategoryId)
    
    // Update the displayed score next to the slider
    // Find the score display in the new design structure
    const parentItem = this.element.closest('.subcategory-item')
    console.log('Parent item found:', !!parentItem)
    if (parentItem) {
      const scoreDisplay = parentItem.querySelector('.subcategory-header span')
      console.log('Score display found:', !!scoreDisplay)
      if (scoreDisplay) {
        // Ensure we're working with a number and format to 1 decimal place
        const formattedScore = parseFloat(score).toFixed(1)
        scoreDisplay.textContent = formattedScore
        // Also update the input value to ensure consistency
        event.target.value = parseFloat(score).toFixed(1)
        console.log('Updated display text to:', formattedScore)
      }
    }
    
    // Send the update to the server
    this.updateSubcategoryScore(subcategoryId, score)
  }
  
  async updateSubcategoryScore(subcategoryId, score) {
    console.log('updateSubcategoryScore called with:', subcategoryId, score)
    // Get the category ID from the URL path
    const pathParts = window.location.pathname.split('/')
    console.log('Path parts:', pathParts)
    const categoryId = pathParts[pathParts.indexOf('categories') + 1]
    console.log('Category ID from URL:', categoryId)
    
    const url = `/categories/${categoryId}/subcategories/${subcategoryId}`
    console.log('Request URL:', url)
    const token = document.querySelector('meta[name="csrf-token"]').content
    console.log('CSRF token found:', !!token)
    
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
      
      console.log('Response status:', response.status, response.ok)
      if (!response.ok) {
        throw new Error('Network response was not ok')
      }
      
      // Handle the response and update the UI
      console.log('Parsing response as JSON')
      const responseData = await response.json()
      console.log('Response data:', responseData)
      
      // Update the category score display
      if (responseData.category_score) {
        console.log('Category score from response:', responseData.category_score)
        const scoreDisplay = document.querySelector('.score-display')
        console.log('Score display element found:', !!scoreDisplay)
        if (scoreDisplay) {
          scoreDisplay.textContent = parseFloat(responseData.category_score).toFixed(1)
          console.log('Updated category score display to:', parseFloat(responseData.category_score).toFixed(1))
        }
      }
      
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
