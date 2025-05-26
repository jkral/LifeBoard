import { Controller } from "@hotwired/stimulus"
import { post } from '@rails/request.js'

export default class extends Controller {
  static targets = ["container"]
  static values = {
    categoryId: Number
  }

  connect() {
    console.log('Goals board controller connected')
    console.log('Category ID:', this.categoryIdValue)
    this.setupDragAndDrop()
    this.loadGoals()
  }

  async loadGoals() {
    try {
      const response = await fetch(`/categories/${this.categoryIdValue}/goals.json`)
      const goals = await response.json()
      this.renderGoals(goals)
    } catch (error) {
      console.error('Error loading goals:', error)
    }
  }

  renderGoals(goals) {
    // Clear existing goals
    document.querySelectorAll('.goal-column').forEach(column => {
      const container = column.querySelector('.goals-container')
      if (container) container.innerHTML = ''
    })

    // Render goals in their respective columns
    Object.entries(goals).forEach(([status, goals]) => {
      const column = document.querySelector(`[data-status="${status}"]`)
      if (!column) return

      const container = column.querySelector('.goals-container') || column
      
      goals.forEach(goal => {
        const goalElement = this.createGoalElement(goal)
        container.appendChild(goalElement)
      })
    })
  }

  createGoalElement(goal) {
    const element = document.createElement('div')
    element.className = 'goal-card'
    element.draggable = true
    element.dataset.goalId = goal.id
    element.dataset.action = 'dragstart->goals-board#dragStart'
    
    element.innerHTML = `
      <div class="goal-title">${this.escapeHtml(goal.title)}</div>
      ${goal.description ? `<div class="goal-desc">${this.escapeHtml(goal.description)}</div>` : ''}
      <div class="goal-actions">
        <button class="edit-goal" data-action="click->goals-board#editGoal">✏️</button>
        <button class="delete-goal" data-action="click->goals-board#deleteGoal">🗑️</button>
      </div>
    `
    
    return element
  }

  async addGoal(event) {
    console.log('Add goal button clicked')
    const title = prompt('Enter goal title:')
    console.log('Entered title:', title)
    if (!title) return

    const description = prompt('Enter description (optional):')
    
    try {
      const response = await post(`/categories/${this.categoryIdValue}/goals.json`, {
        body: JSON.stringify({
          goal: {
            title: title,
            description: description,
            status: 'todo' // Always add to 'todo' column
          }
        }),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.csrfToken()
        }
      })
      
      if (response.ok) {
        this.loadGoals()
      } else {
        const error = await response.text()
        alert(`Error: ${error}`)
      }
    } catch (error) {
      console.error('Error creating goal:', error)
      alert('Failed to create goal')
    }
  }

  async editGoal(event) {
    event.stopPropagation()
    const goalCard = event.target.closest('.goal-card')
    const goalId = goalCard.dataset.goalId
    
    const title = prompt('Edit title:', goalCard.querySelector('.goal-title').textContent)
    if (title === null) return
    
    const descElement = goalCard.querySelector('.goal-desc')
    const currentDesc = descElement ? descElement.textContent : ''
    const description = prompt('Edit description (optional):', currentDesc)
    
    try {
      const response = await fetch(`/categories/${this.categoryIdValue}/goals/${goalId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.csrfToken()
        },
        body: JSON.stringify({
          goal: {
            title: title,
            description: description
          }
        })
      })
      
      if (response.ok) {
        this.loadGoals()
      } else {
        const error = await response.text()
        alert(`Error: ${error}`)
      }
    } catch (error) {
      console.error('Error updating goal:', error)
      alert('Failed to update goal')
    }
  }

  async deleteGoal(event) {
    event.stopPropagation()
    if (!confirm('Are you sure you want to delete this goal?')) return
    
    const goalCard = event.target.closest('.goal-card')
    const goalId = goalCard.dataset.goalId
    
    try {
      const response = await fetch(`/categories/${this.categoryIdValue}/goals/${goalId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': this.csrfToken()
        }
      })
      
      if (response.ok) {
        goalCard.remove()
      } else {
        const error = await response.text()
        alert(`Error: ${error}`)
      }
    } catch (error) {
      console.error('Error deleting goal:', error)
      alert('Failed to delete goal')
    }
  }

  // Drag and Drop Handlers
  dragStart(event) {
    event.dataTransfer.setData('text/plain', event.target.dataset.goalId)
    event.dataTransfer.effectAllowed = 'move'
    event.target.classList.add('dragging')
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = 'move'
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
    const newStatus = event.currentTarget.closest('.goal-column').dataset.status
    
    // Get the position (index) where the goal was dropped
    const container = event.currentTarget.closest('.goals-container') || event.currentTarget
    const rect = container.getBoundingClientRect()
    const y = event.clientY - rect.top
    const cards = Array.from(container.querySelectorAll('.goal-card:not(.dragging)'))
    
    let position = 0
    for (const card of cards) {
      const cardRect = card.getBoundingClientRect()
      const cardMiddle = cardRect.top + (cardRect.height / 2) - rect.top
      
      if (y < cardMiddle) {
        break
      }
      position++
    }
    
    try {
      const response = await fetch(`/categories/${this.categoryIdValue}/goals/${goalId}/move`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.csrfToken()
        },
        body: JSON.stringify({
          status: newStatus,
          position: position
        })
      })
      
      if (response.ok) {
        this.loadGoals()
      } else {
        const error = await response.text()
        console.error('Error moving goal:', error)
      }
    } catch (error) {
      console.error('Error moving goal:', error)
    }
  }

  dragEnd(event) {
    document.querySelectorAll('.goal-card').forEach(el => {
      el.classList.remove('dragging', 'drag-over')
    })
  }

  // Helper methods
  setupDragAndDrop() {
    // Make columns drop targets
    document.querySelectorAll('.goal-column').forEach(column => {
      column.addEventListener('dragover', this.dragOver.bind(this))
      column.addEventListener('dragenter', this.dragEnter.bind(this))
      column.addEventListener('dragleave', this.dragLeave.bind(this))
      column.addEventListener('drop', this.drop.bind(this))
    })

    // Make goal cards draggable
    document.addEventListener('dragend', this.dragEnd.bind(this))
  }

  escapeHtml(unsafe) {
    return unsafe
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;")
  }

  csrfToken() {
    return document.querySelector("meta[name='csrf-token']").getAttribute("content")
  }
}
