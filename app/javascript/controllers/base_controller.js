import { Controller } from "@hotwired/stimulus"

// Base controller with common functionality for all controllers
export default class extends Controller {
  // Get CSRF token from meta tag
  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }
  
  // Show a flash message
  showFlash(message, type = 'notice') {
    const event = new CustomEvent('flash:show', { 
      detail: { message, type }
    })
    window.dispatchEvent(event)
  }
  
  // Handle API errors consistently
  handleApiError(error) {
    console.error('API Error:', error)
    this.showFlash(error.message || 'An error occurred. Please try again.', 'error')
    throw error // Re-throw to allow further error handling if needed
  }
  
  // Debounce function for rate-limiting
  debounce(func, wait) {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  }
  
  // Make a fetch request with CSRF token and JSON headers
  async fetchJson(url, options = {}) {
    const headers = {
      'Content-Type': 'application/json',
      'X-CSRF-Token': this.csrfToken,
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      ...options.headers
    }
    
    try {
      const response = await fetch(url, { ...options, headers })
      
      if (!response.ok) {
        const error = await response.json().catch(() => ({}))
        throw new Error(error.message || `HTTP error! status: ${response.status}`)
      }
      
      // For 204 No Content responses
      if (response.status === 204) return null
      
      return await response.json()
    } catch (error) {
      return this.handleApiError(error)
    }
  }
}
