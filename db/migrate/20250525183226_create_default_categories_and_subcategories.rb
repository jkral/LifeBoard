class CreateDefaultCategoriesAndSubcategories < ActiveRecord::Migration[7.0]
  def up
    # Create default categories
    categories = [
      { name: 'Health', description: 'Physical and Mental Well-being', position: 1 },
      { name: 'Personal', description: 'Relationships and Personal Growth', position: 2 },
      { name: 'Professional', description: 'Career and Skills Development', position: 3 }
    ]
    
    categories_data = categories.map do |cat_attrs|
      category = Category.find_or_create_by!(name: cat_attrs[:name]) do |c|
        c.description = cat_attrs[:description]
        c.position = cat_attrs[:position]
        c.score = 5.0 # Default score
      end
      { id: category.id, name: category.name }
    end
    
    # Create default subcategories for each category
    subcategories_data = {
      'Health' => [
        { name: 'Physical', description: 'Exercise, nutrition, and physical health', position: 1 },
        { name: 'Mental', description: 'Emotional and psychological well-being', position: 2 },
        { name: 'Lifestyle', description: 'Sleep, habits, and daily routines', position: 3 }
      ],
      'Personal' => [
        { name: 'Relationships', description: 'Family, friends, and social connections', position: 1 },
        { name: 'Growth', description: 'Learning and personal development', position: 2 },
        { name: 'Finance', description: 'Personal finances and financial goals', position: 3 }
      ],
      'Professional' => [
        { name: 'Career', description: 'Job satisfaction and career progression', position: 1 },
        { name: 'Skills', description: 'Professional skills and competencies', position: 2 },
        { name: 'Work Environment', description: 'Workplace and team dynamics', position: 3 }
      ]
    }
    
    categories_data.each do |category|
      category_name = category[:name]
      if subcategories = subcategories_data[category_name]
        subcategories.each do |subcat_attrs|
          Subcategory.find_or_create_by!(
            category_id: category[:id],
            name: subcat_attrs[:name]
          ) do |subcat|
            subcat.description = subcat_attrs[:description]
            subcat.position = subcat_attrs[:position]
            subcat.score = 5.0 # Default score
          end
        end
      end
    end
  end
  
  def down
    # No need to do anything as we don't want to delete user data on rollback
  end
end
