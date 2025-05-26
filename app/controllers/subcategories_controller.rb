class SubcategoriesController < ApplicationController
  before_action :require_authentication
  before_action :set_subcategory, only: [:show, :update]

  def show
  end

  def update
    @category = @subcategory.category
    
    # Use a transaction to ensure both updates succeed or fail together
    ActiveRecord::Base.transaction do
      if @subcategory.update(subcategory_params)
        # Force update the category score in the same transaction
        @category.update_score
        
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to category_path(@category), notice: 'Score updated successfully' }
          format.json { 
            render json: { 
              success: true, 
              subcategory_score: @subcategory.score.to_f,
              category_score: @category.reload.score.to_f  # Reload to get the latest value
            } 
          }
        end
      else
        raise ActiveRecord::Rollback
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::Rollback
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to category_path(@category), alert: 'Failed to update score' }
        format.json { 
          render json: { 
            success: false, 
            errors: @subcategory.errors.full_messages 
          }, status: :unprocessable_entity 
        }
      end
    end
  end

  private

  def set_subcategory
    @subcategory = current_user.subcategories.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Subcategory not found or access denied'
  end

  def subcategory_params
    params.require(:subcategory).permit(:score)
  end
end
