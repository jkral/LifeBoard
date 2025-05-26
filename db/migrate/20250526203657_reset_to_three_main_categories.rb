class ResetToThreeMainCategories < ActiveRecord::Migration[8.0]
  def up
    # First, remove all existing data
    execute "TRUNCATE subcategories RESTART IDENTITY CASCADE"
    execute "TRUNCATE categories RESTART IDENTITY CASCADE"
    
    # Create the three main categories with their subcategories
    categories = [
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
    
    # For each user, create their categories
    User.find_each do |user|
      categories.each do |cat_attrs|
        # Create a copy of the hash to avoid modifying the original
        cat_attrs_copy = cat_attrs.dup
        subcategories = cat_attrs_copy.delete(:subcategories) || []
        
        category = user.categories.create!(cat_attrs_copy.merge(score: 10.0))
        
        subcategories.each do |sub_attrs|
          category.subcategories.create!(sub_attrs.merge(score: 10.0, user_id: user.id))
        end
      end
    end
  end
  
  def down
    # This migration cannot be reversed as it would be destructive
    raise ActiveRecord::IrreversibleMigration
  end
end
