class Category < ApplicationRecord
  has_many :subcategories, -> { order(position: :asc) }, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :position, presence: true, numericality: { only_integer: true }
  
  # Score is calculated as the average of active subcategory scores
  def calculate_score
    active_subs = subcategories.active
    return 0 if active_subs.empty?
    active_subs.average(:score).round(1)
  end
  
  # Update the score based on active subcategories
  def update_score
    update_column(:score, calculate_score)
  end
  
  # Class method to get the total score (average of all category scores)
  def self.total_score
    average(:score).to_f.round(1)
  end
  
  # Get only active subcategories
  def active_subcategories
    subcategories.active
  end
end
