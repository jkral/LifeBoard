class DashboardController < ApplicationController
  before_action :require_authentication
  
  def index
    if current_user.nil?
      redirect_to login_path, alert: "Please log in to continue."
      return
    end
    
    @categories = Category.includes(:subcategories).order(:position)
    @total_score = calculate_total_score
  end
  
  private
  
  def calculate_total_score
    active_categories = Category.joins(:subcategories).where(subcategories: { active: true }).distinct
    return 0.0 if active_categories.empty?
    
    active_categories.average('COALESCE(categories.score, 0)').to_f.round(1)
  end
end
