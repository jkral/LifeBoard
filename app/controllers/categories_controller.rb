class CategoriesController < ApplicationController
  before_action :require_authentication
  before_action :set_category, only: [:show, :update, :force_score]

  def show
    @subcategories = @category.subcategories.active.order(:position)
  end
  
  # Update the category score directly
  def update
    if @category.update(category_params)
      render json: { success: true }
    else
      render json: { success: false, errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # Force the category score to be exactly 10.0
  def force_score
    # Only allow forcing to 10.0 if all subcategories are at 10.0
    subcategories = @category.subcategories.active
    all_at_10 = subcategories.all? { |sub| sub.score.to_f >= 9.95 }
    
    if all_at_10
      # Force update the score to exactly 10.0
      @category.update_column(:score, 10.0)
      
      # Return success response
      render json: { success: true, category_score: 10.0 }
    else
      # Return error if not all subcategories are at 10.0
      render json: { success: false, message: 'Not all subcategories are at 10.0' }, status: :unprocessable_entity
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end
  
  def category_params
    params.require(:category).permit(:score)
  end
end
