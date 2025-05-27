import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="score-slider"
export default class extends Controller {
  static values = {
    subcategoryId: Number
  }

  connect() {
    // Initialize the slider with the current value from the database
    const initialValue = this.element.value
    this.updateDisplay(initialValue)
    
    // Add event listener for score updates from other sources
    document.addEventListener('score-updated', this.handleScoreUpdate.bind(this))
  }

  disconnect() {
    // Clean up event listener
    document.removeEventListener('score-updated', this.handleScoreUpdate.bind(this))
  }

  handleScoreUpdate(event) {
    // Only update if this is the affected subcategory
    if (event.detail.subcategoryId === this.subcategoryIdValue) {
      this.updateDisplay(event.detail.score)
      this.element.value = event.detail.score
    }
  }

  updateScore(event) {
    const score = event.target.value
    const subcategoryId = this.subcategoryIdValue
    
    // Update the displayed score immediately for better UX
    this.updateDisplay(score)
    
    // Send the update to the server
    this.updateSubcategoryScore(subcategoryId, score)
  }
  
  updateDisplay(score) {
    const parentItem = this.element.closest('.subcategory-item')
    if (parentItem) {
      const scoreDisplay = parentItem.querySelector('.subcategory-header span:last-child')
      if (scoreDisplay) {
        // Format to 1 decimal place
        const formattedScore = parseFloat(score).toFixed(1)
        scoreDisplay.textContent = formattedScore
      }
    }
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
            score: parseFloat(score).toFixed(1)
          } 
        })
      })

      if (!response.ok) {
        throw new Error('Network response was not ok')
      }
      
      const data = await response.json()
      
      if (!data.success) {
        throw new Error(data.errors?.join(', ') || 'Failed to update score')
      }
      
      // Update the category score display
      if (data.category_score !== undefined) {
        const scoreDisplay = document.querySelector(`#category_${categoryId}_score .score-display`)
        if (scoreDisplay) {
          scoreDisplay.textContent = parseFloat(data.category_score).toFixed(1)
        }
      }
      
      // Update the subcategory score display with the server's value
      if (data.subcategory_score !== undefined) {
        this.updateDisplay(data.subcategory_score)
        this.element.value = data.subcategory_score
      }
      
      // Update total score if we're on the dashboard
      if (data.total_score !== undefined) {
        const totalScoreDisplay = document.querySelector('#total_score .text-4xl')
        if (totalScoreDisplay) {
          totalScoreDisplay.textContent = parseFloat(data.total_score).toFixed(1)
        }
      }
      
      // Dispatch a custom event to notify other components
      const event = new CustomEvent('score-updated', {
        detail: {
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          score: data.subcategory_score,
          categoryScore: data.category_score,
          totalScore: data.total_score
        }
      })
      document.dispatchEvent(event)
      
    } catch (error) {
      console.error('Error updating score:', error)
      // Revert the display to the previous value
      this.updateDisplay(this.element.value)
      
      // Show error message
      const errorDisplay = document.createElement('div')
      errorDisplay.className = 'error-message'
      errorDisplay.textContent = 'Failed to update score. Please try again.'
      
      const container = this.element.closest('.slider-container')
      if (container) {
        const existingError = container.querySelector('.error-message')
        if (existingError) {
          existingError.remove()
        }
        container.appendChild(errorDisplay)
        
        // Remove error after 5 seconds
        setTimeout(() => errorDisplay.remove(), 5000)
      }
    }
  }
}

