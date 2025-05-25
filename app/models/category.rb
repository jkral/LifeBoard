class Category < ApplicationRecord
  has_many :subcategories, -> { order(position: :asc) }, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :position, presence: true, numericality: { only_integer: true }
  
  # Score is calculated as the average of subcategory scores
  def calculate_score
    return 0 if subcategories.empty?
    subcategories.average(:score).round(1)
  end
  
  # Update the score based on subcategories
  def update_score
    update_column(:score, calculate_score)
  end
  
  # Class method to get the total score (average of all category scores)
  def self.total_score
    average(:score).to_f.round(1)
  end
end
