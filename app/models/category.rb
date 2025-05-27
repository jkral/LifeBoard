class Category < ApplicationRecord
  belongs_to :user
  has_many :subcategories, -> { order(position: :asc) }, dependent: :destroy
  has_many :goals, -> { order(position: :asc) }, dependent: :destroy
  
  # Set default score
  attribute :score, :decimal, default: 10.0
  
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :position, presence: true, numericality: { only_integer: true }, uniqueness: { scope: :user_id }
  validates :score, presence: true, numericality: { 
    greater_than_or_equal_to: 1.0, 
    less_than_or_equal_to: 10.0,
    message: 'must be between 1.0 and 10.0'
  }
  
  # Score is calculated as the average of active subcategory scores
  def calculate_score
    active_subs = subcategories.active
    return 10.0 if active_subs.empty? # Default to 10.0 if no active subcategories
    
    # Convert all scores to float to ensure consistent behavior
    scores = active_subs.pluck(:score).map(&:to_f)
    
    # Special case: if all subcategories are 10.0 (or very close to it), return exactly 10.0
    if scores.all? { |score| score >= 9.95 }
      return 10.0
    end
    
    # Calculate average with proper rounding
    total = scores.sum
    count = scores.size
    average = total / count
    
    # Round to 1 decimal place and ensure we don't get values like 9.9999999
    (average * 10).round.to_f / 10
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
    return 10.0 if active_categories.empty? # Default to 10.0 if no active categories
    
    # Special case: if all categories are 10.0, ensure the result is exactly 10.0
    if active_categories.all? { |cat| cat.score.to_f >= 9.95 }
      return 10.0
    end
    
    # Calculate with higher precision to avoid rounding errors
    scores = active_categories.pluck(:score).map(&:to_f)
    total = scores.sum
    count = scores.size
    average = total / count
    
    # Round to 1 decimal place
    (average * 10).round.to_f / 10
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
