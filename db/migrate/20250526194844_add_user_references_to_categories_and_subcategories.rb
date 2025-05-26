class AddUserReferencesToCategoriesAndSubcategories < ActiveRecord::Migration[8.0]
  def change
    add_reference :categories, :user, null: false, foreign_key: true, default: 1
    add_reference :subcategories, :user, null: false, foreign_key: true, default: 1
    
    # Add index for better query performance
    add_index :categories, [:user_id, :name], unique: true
    add_index :subcategories, [:user_id, :name], unique: true
  end
end
