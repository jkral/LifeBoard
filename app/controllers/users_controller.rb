class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    
    begin
      if @user.save
        # Set up default categories and subcategories for the new user
        setup_default_categories_for_user(@user)
        
        start_new_session_for(@user)
        redirect_to root_path, notice: "Welcome to LifeBoard!"
      else
        render :new, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique => e
      @user.errors.add(:email_address, 'has already been taken')
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :name)
  end
  
  def setup_default_categories_for_user(user)
    # Define default categories and their subcategories
    default_categories = [
      {
        name: 'Health',
        score: 10.0,
        position: 1,
        subcategories: [
          { name: 'Exercise', score: 10.0, position: 1, active: true },
          { name: 'Nutrition', score: 10.0, position: 2, active: true },
          { name: 'Sleep', score: 10.0, position: 3, active: true }
        ]
      },
      {
        name: 'Career',
        score: 10.0,
        position: 2,
        subcategories: [
          { name: 'Productivity', score: 10.0, position: 1, active: true },
          { name: 'Growth', score: 10.0, position: 2, active: true },
          { name: 'Satisfaction', score: 10.0, position: 3, active: true }
        ]
      },
      {
        name: 'Relationships',
        score: 10.0,
        position: 3,
        subcategories: [
          { name: 'Family', score: 10.0, position: 1, active: true },
          { name: 'Friends', score: 10.0, position: 2, active: true },
          { name: 'Romantic', score: 10.0, position: 3, active: true }
        ]
      },
      {
        name: 'Finance',
        score: 10.0,
        position: 4,
        subcategories: [
          { name: 'Savings', score: 10.0, position: 1, active: true },
          { name: 'Income', score: 10.0, position: 2, active: true },
          { name: 'Investments', score: 10.0, position: 3, active: true }
        ]
      },
      {
        name: 'Personal Growth',
        score: 10.0,
        position: 5,
        subcategories: [
          { name: 'Learning', score: 10.0, position: 1, active: true },
          { name: 'Hobbies', score: 10.0, position: 2, active: true },
          { name: 'Mindfulness', score: 10.0, position: 3, active: true }
        ]
      }
    ]
    
    # Create categories and subcategories for the new user
    default_categories.each do |category_attrs|
      subcategories_attrs = category_attrs.delete(:subcategories)
      category = user.categories.create!(category_attrs)
      
      subcategories_attrs.each do |subcategory_attrs|
        category.subcategories.create!(subcategory_attrs.merge(user_id: user.id))
      end
    end
  end
end
