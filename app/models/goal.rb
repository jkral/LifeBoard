class Goal < ApplicationRecord
  # Associations
  belongs_to :category
  belongs_to :user

  # Validations
  validates :title, presence: true, length: { maximum: 100 }
  validates :status, presence: true, inclusion: { in: %w[todo in_progress done] }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :category_id, presence: true
  validates :user_id, presence: true

  # Scopes
  scope :for_category, ->(category_id) { where(category_id: category_id) }
  scope :with_status, ->(status) { where(status: status) }
  scope :ordered, -> { order(:position) }

  # Callbacks
  before_validation :set_default_position, on: :create

  private

  def set_default_position
    return if position.present?
    
    max_position = self.class.where(
      category_id: category_id,
      status: status
    ).maximum(:position) || -1
    
    self.position = max_position + 1
  end
end
