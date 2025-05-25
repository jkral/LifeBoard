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
    
    (total.to_f / count).round(1)
  end
  
  # Update the score based on active subcategories
  def update_score
    new_score = calculate_score
    update_column(:score, new_score)
    new_score
  end
  
  # Class method to get the total score (average of all category scores)
  def self.total_score
    active_categories = joins(:subcategories).where(subcategories: { active: true }).distinct
    return 0.0 if active_categories.empty?
    
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
