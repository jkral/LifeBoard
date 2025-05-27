class SubcategoriesController < ApplicationController
  before_action :require_authentication
  before_action :set_subcategory, only: [:show, :update]

  def show
  end

  def update
    @category = @subcategory.category
    
    # Use a transaction to ensure both updates succeed or fail together
    ActiveRecord::Base.transaction do
      # Validate the score before updating
      score = subcategory_params[:score].to_f
      if score < 1.0 || score > 10.0
        raise ActiveRecord::RecordInvalid.new(@subcategory)
      end
      
      if @subcategory.update(subcategory_params)
        # Force update the category score in the same transaction
        @category.update_score
        
        # Broadcast the update to all connected clients
        Turbo::StreamsChannel.broadcast_update_to(
          @category,
          target: dom_id(@category, :score),
          partial: "categories/score",
          locals: { category: @category }
        )
        
        # Also broadcast to the specific subcategory
        Turbo::StreamsChannel.broadcast_update_to(
          @subcategory,
          target: dom_id(@subcategory),
          partial: "subcategories/subcategory",
          locals: { subcategory: @subcategory }
        )
        
        # Broadcast to the dashboard for total score update
        Turbo::StreamsChannel.broadcast_update_to(
          "dashboard",
          target: "total_score",
          partial: "dashboard/total_score",
          locals: { total_score: Category.total_score }
        )
        
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to category_path(@category), notice: 'Score updated successfully' }
          format.json { 
            render json: { 
              success: true, 
              subcategory_score: @subcategory.score.to_f,
              category_score: @category.reload.score.to_f,  # Reload to get the latest value
              total_score: Category.total_score
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
