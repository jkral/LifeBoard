class Subcategory < ApplicationRecord
  belongs_to :category, touch: true
  belongs_to :user
  
  # Set default values
  attribute :active, :boolean, default: true
  attribute :score, :decimal, default: 10.0
  
  validates :name, presence: true, uniqueness: { scope: [:category_id, :user_id] }
  validates :position, presence: true, numericality: { only_integer: true }
  validates :score, presence: true, numericality: { 
    greater_than_or_equal_to: 1.0, 
    less_than_or_equal_to: 10.0,
    message: 'must be between 1.0 and 10.0'
  }
  
  after_save :update_category_score
  after_destroy :update_category_score
  
  # Scope for active subcategories
  scope :active, -> { where(active: true) }
  
  private
  
  def update_category_score
    # This will trigger the after_touch callback on the category
    category.touch
  end
end
