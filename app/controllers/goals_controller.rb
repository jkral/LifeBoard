class GoalsController < ApplicationController
  before_action :require_authentication
  before_action :set_goal, only: [:update, :destroy, :move]
  before_action :set_category
  before_action :authorize_goal, except: [:index, :create]

  def index
    @goals = {
      todo: goals_for_status('todo'),
      in_progress: goals_for_status('in_progress'),
      done: goals_for_status('done')
    }

    respond_to do |format|
      format.json { render json: @goals }
      format.html
    end
  end

  def create
    @goal = @category.goals.new(goal_params)
    @goal.user = current_user
    @goal.status = params[:status] || 'todo'

    if @goal.save
      render json: @goal, status: :created
    else
      render json: { errors: @goal.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @goal.update(goal_params)
      render json: @goal
    else
      render json: { errors: @goal.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @goal.destroy
    head :no_content
  end

  def move
    new_status = params[:status]
    new_position = params[:position].to_i
    
    Goal.transaction do
      # Remove from old position
      @category.goals
               .where(status: @goal.status)
               .where('position > ?', @goal.position)
               .update_all('position = position - 1')
      
      # Make room in the new position
      @category.goals
               .where(status: new_status)
               .where('position >= ?', new_position)
               .update_all('position = position + 1')
      
      # Update the goal
      @goal.update!(
        status: new_status,
        position: new_position
      )
    end
    
    head :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  private

  def set_category
    @category = current_user.categories.find(params[:category_id])
  end

  def set_goal
    @goal = current_user.goals.find(params[:id])
  end

  def authorize_goal
    return if @goal.user_id == current_user.id
    
    render json: { error: 'Not authorized' }, status: :forbidden
  end

  def goal_params
    params.require(:goal).permit(:title, :description, :position, :status)
  end

  def goals_for_status(status)
    @category.goals
             .with_status(status)
             .ordered
             .map { |g| goal_json(g) }
  end

  def goal_json(goal)
    {
      id: goal.id,
      title: goal.title,
      description: goal.description,
      status: goal.status,
      position: goal.position,
      category_id: goal.category_id,
      user_id: goal.user_id,
      created_at: goal.created_at,
      updated_at: goal.updated_at
    }
  end
end
