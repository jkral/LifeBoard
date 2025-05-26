class Category < ApplicationRecord
  has_many :subcategories, -> { order(position: :asc) }, dependent: :destroy
  
  # Set default score
  attribute :score, :decimal, default: 10.0
  
  validates :name, presence: true, uniqueness: true
  validates :position, presence: true, numericality: { only_integer: true }
  
  # Score is calculated as the average of active subcategory scores
  def calculate_score
    active_subs = subcategories.active
    return 0 if active_subs.empty?
    
    total = active_subs.sum(:score)
    count = active_subs.count
    
    # Special case: if all subcategories are 10.0, ensure the result is exactly 10.0
    if active_subs.all? { |sub| sub.score.to_f >= 9.95 }
      return 10.0
    end
    
    # Calculate with higher precision to avoid rounding errors
    (total.to_f / count).round(1)
  end
  
  # Update the score based on active subcategories
  # Uses update_column to skip validations and callbacks to prevent infinite loops
  def update_score
    new_score = calculate_score
    
    # Only update if the score has actually changed to avoid unnecessary database writes
    if score != new_score
      update_column(:score, new_score)
      # Ensure the updated_at is touched to invalidate caches
      touch if persisted?
    end
    
    new_score
  end
  
  # Class method to get the total score (average of all category scores)
  def self.total_score
    active_categories = joins(:subcategories).where(subcategories: { active: true }).distinct
    return 0 if active_categories.empty?
    
    # Special case: if all categories are 10.0, ensure the result is exactly 10.0
    if active_categories.all? { |cat| cat.score.to_f >= 9.95 }
      return 10.0
    end
    
    # Calculate with higher precision to avoid rounding errors
    active_categories.average(:score).to_f.round(1)
  end
  
  # Get only active subcategories
  def active_subcategories
    subcategories.active
  end
  
  # After save callback to update the score if subcategories change
  after_save :update_score, if: :saved_change_to_score?
  
  # After any subcategory is updated, update the category score
  after_touch :update_score
  
  # Update all category scores
  def self.update_all_scores
    find_each(&:update_score)
  end
end
