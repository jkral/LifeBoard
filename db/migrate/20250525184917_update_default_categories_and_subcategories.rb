class UpdateDefaultCategoriesAndSubcategories < ActiveRecord::Migration[7.0]
  def up
    # Reset all existing data
    Subcategory.delete_all
    Category.delete_all
    
    # Create default categories with updated structure
    categories = [
      { name: 'Health', description: 'Physical, Mental, and Spiritual Well-being', position: 1 },
      { name: 'Personal', description: 'Relationships and Personal Life', position: 2 },
      { name: 'Professional', description: 'Work, Passion, and Education', position: 3 }
    ]
    
    categories_data = categories.map do |cat_attrs|
      category = Category.create!(
        name: cat_attrs[:name],
        description: cat_attrs[:description],
        position: cat_attrs[:position],
        score: 10.0 # Default score set to 10
      )
      { id: category.id, name: category.name }
    end
    
    # Create updated subcategories for each category
    subcategories_data = {
      'Health' => [
        { name: 'Mental', description: 'Emotional and psychological well-being', position: 1 },
        { name: 'Physical', description: 'Exercise, nutrition, and physical health', position: 2 },
        { name: 'Spiritual', description: 'Inner peace and spiritual growth', position: 3 }
      ],
      'Personal' => [
        { name: 'Partner', description: 'Romantic relationship', position: 1 },
        { name: 'Family', description: 'Family relationships', position: 2 },
        { name: 'Social', description: 'Friends and social connections', position: 3 }
      ],
      'Professional' => [
        { name: 'Work', description: 'Current job and career', position: 1 },
        { name: 'Passion', description: 'Personal projects and passions', position: 2 },
        { name: 'Education', description: 'Learning and skill development', position: 3 }
      ]
    }
    
    categories_data.each do |category|
      category_name = category[:name]
      if subcategories = subcategories_data[category_name]
        subcategories.each do |subcat_attrs|
          Subcategory.create!(
            category_id: category[:id],
            name: subcat_attrs[:name],
            description: subcat_attrs[:description],
            position: subcat_attrs[:position],
            score: 10.0 # Default score set to 10
          )
        end
        
        # Update category score to reflect the average of subcategories (should be 10.0)
        Category.find(category[:id]).update_score
      end
    end
  end
  
  def down
    # This migration cannot be reversed as it's a data update
  end
end
