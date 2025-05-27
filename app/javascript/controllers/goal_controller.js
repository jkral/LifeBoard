import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static values = { id: String }

  connect() {
    this.element.dataset.goalId = this.idValue
  }

  dragStart(event) {
    event.dataTransfer.setData('text/plain', this.idValue)
    event.dataTransfer.effectAllowed = 'move'
    
    // Add a class to the dragged item for styling
    event.currentTarget.classList.add('dragging')
    
    // Remove the class when the drag ends
    const handleDragEnd = () => {
      event.currentTarget.classList.remove('dragging')
      document.removeEventListener('dragend', handleDragEnd)
    }
    
    document.addEventListener('dragend', handleDragEnd, { once: true })
  }

  // Add these helper methods for drag and drop
  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = 'move'
    event.currentTarget.classList.add('drag-over')
  }

  dragEnter(event) {
    event.preventDefault()
    event.currentTarget.classList.add('drag-over')
  }

  dragLeave(event) {
    event.currentTarget.classList.remove('drag-over')
  }

  async drop(event) {
    event.preventDefault()
    event.currentTarget.classList.remove('drag-over')
    
    const goalId = event.dataTransfer.getData('text/plain')
    const newStatus = event.currentTarget.closest('[data-status]').dataset.status
    
    try {
      const response = await fetch(`/goals/${goalId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ goal: { status: newStatus } })
      })
      
      if (!response.ok) {
        throw new Error('Failed to update goal status')
      }
      
      // The Turbo Stream response will handle updating the UI
    } catch (error) {
      console.error('Error updating goal status:', error)
      // You might want to show an error message to the user here
    }
  }
}
