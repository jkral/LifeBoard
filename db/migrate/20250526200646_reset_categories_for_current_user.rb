class ResetCategoriesForCurrentUser < ActiveRecord::Migration[8.0]
  def up
    # Find the first user
    user = User.first
    return unless user
    
    # Delete existing categories and subcategories for this user
    user.categories.destroy_all
    
    # Create default categories
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
    
    # Create categories and subcategories
    default_categories.each do |cat_attrs|
      subcategories = cat_attrs.delete(:subcategories)
      category = user.categories.create!(cat_attrs)
      
      subcategories.each do |sub_attrs|
        category.subcategories.create!(sub_attrs.merge(user_id: user.id))
      end
    end
  end
  
  def down
    # This migration cannot be reversed
    raise ActiveRecord::IrreversibleMigration
  end
end
