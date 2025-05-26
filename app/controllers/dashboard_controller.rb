class DashboardController < ApplicationController
  before_action :require_authentication
  
  def index
    if current_user.nil?
      redirect_to login_path, alert: "Please log in to continue."
      return
    end
    
    # Ensure we have exactly 3 categories with their subcategories
    ensure_default_categories
    
    # Load categories with their subcategories, ordered by position
    @categories = current_user.categories.includes(:subcategories).order(:position)
    @total_score = calculate_total_score
    
    # Debug output
    if Rails.env.development?
      Rails.logger.info "Loaded #{@categories.size} categories for user #{current_user.id}"
      @categories.each do |cat|
        Rails.logger.info "#{cat.name} (Position: #{cat.position}) - Score: #{cat.score}"
        cat.subcategories.each do |sub|
          Rails.logger.info "  - #{sub.name} (Position: #{sub.position}): #{sub.score}"
        end
      end
      Rails.logger.info "Total Score: #{@total_score}"
    end
  end
  
  private
  
  def ensure_default_categories
    # Define our three main categories with their subcategories
    default_categories = [
      {
        name: 'Health',
        position: 1,
        subcategories: [
          { name: 'Mental', position: 1, active: true },
          { name: 'Physical', position: 2, active: true },
          { name: 'Spiritual', position: 3, active: true }
        ]
      },
      {
        name: 'Personal',
        position: 2,
        subcategories: [
          { name: 'Partner', position: 1, active: true },
          { name: 'Family', position: 2, active: true },
          { name: 'Social', position: 3, active: true }
        ]
      },
      {
        name: 'Professional',
        position: 3,
        subcategories: [
          { name: 'Work', position: 1, active: true },
          { name: 'Education', position: 2, active: true },
          { name: 'Passion', position: 3, active: true }
        ]
      }
    ]
    
    # If we don't have exactly 3 categories, reset them
    if current_user.categories.count != 3
      current_user.categories.destroy_all
      
      default_categories.each do |cat_attrs|
        subcategories = cat_attrs.delete(:subcategories)
        category = current_user.categories.create!(cat_attrs.merge(score: 10.0))
        
        subcategories.each do |sub_attrs|
          category.subcategories.create!(sub_attrs.merge(score: 10.0, user_id: current_user.id))
        end
      end
    end
  rescue => e
    Rails.logger.error "Error ensuring default categories: #{e.message}"
    raise e
  end
  
  private
  
  def calculate_total_score
    active_categories = current_user.categories
                                 .joins(:subcategories)
                                 .where(subcategories: { active: true })
                                 .distinct
    return 0.0 if active_categories.empty?
    
    active_categories.average('COALESCE(categories.score, 0)').to_f.round(1)
  end
end
