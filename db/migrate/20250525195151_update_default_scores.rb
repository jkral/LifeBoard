class UpdateDefaultScores < ActiveRecord::Migration[8.0]
  def up
    # Safely update categories table if it exists and has score column
    if table_exists?(:categories) && column_exists?(:categories, :score)
      change_column_default :categories, :score, 10.0
      Category.where(score: 1.0).update_all(score: 10.0)
    end
    
    # Safely update subcategories table if it exists and has score column
    if table_exists?(:subcategories) && column_exists?(:subcategories, :score)
      change_column_default :subcategories, :score, 10.0
      Subcategory.where(score: 1.0).update_all(score: 10.0)
    end
  end
  
  def down
    # Revert back to the original default of 1.0 if needed
    if table_exists?(:categories) && column_exists?(:categories, :score)
      change_column_default :categories, :score, 1.0
    end
    
    if table_exists?(:subcategories) && column_exists?(:subcategories, :score)
      change_column_default :subcategories, :score, 1.0
    end
    
    # Note: We don't update existing records in the down migration
    # as we can't distinguish between user-set values and default values
  end
end
