class AddScoreToCategories < ActiveRecord::Migration[8.0]
  def up
    # Only add the column if it doesn't exist
    unless column_exists?(:categories, :score)
      add_column :categories, :score, :decimal, precision: 3, scale: 1, default: 10.0, null: false
    end
    
    # Ensure the default is set to 10.0
    change_column_default :categories, :score, 10.0
    
    # Update any existing NULL values to 10.0
    Category.where(score: nil).update_all(score: 10.0)
  end
  
  def down
    # Don't remove the column as it might be in use
    # Just revert the default value
    change_column_default :categories, :score, 1.0
  end
end
