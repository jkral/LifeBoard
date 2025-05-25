class SubcategoriesController < ApplicationController
  before_action :require_authentication
  before_action :set_subcategory, only: [:show, :update]

  def show
  end

  def update
    if @subcategory.update(subcategory_params)
      # The category's after_touch callback will handle the score update
      @category = @subcategory.category
      @subcategories = @category.subcategories.active.order(:position)
      
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to category_path(@category), notice: 'Score updated successfully' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error }
        format.html { redirect_to category_path(@subcategory.category), alert: 'Failed to update score' }
      end
    end
  end

  private

  def set_subcategory
    @subcategory = Subcategory.find(params[:id])
  end

  def subcategory_params
    params.require(:subcategory).permit(:score)
  end
end
