class Subcategory < ApplicationRecord
  belongs_to :category
  
  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  validates :score, presence: true, numericality: { 
    greater_than_or_equal_to: 1.0, 
    less_than_or_equal_to: 10.0,
    message: 'must be between 1.0 and 10.0'
  }
  
  after_save :update_category_score
  after_destroy :update_category_score
  
  private
  
  def update_category_score
    category.update_score
  end
end
