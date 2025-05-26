class RemoveUniqueIndexOnCategoriesName < ActiveRecord::Migration[8.0]
  def up
    # Remove the old index that enforces unique names globally
    remove_index :categories, name: 'idx_16548_index_categories_on_name' if index_name_exists?(:categories, 'idx_16548_index_categories_on_name')
    
    # Ensure we have the compound index for user_id and name
    unless index_name_exists?(:categories, 'index_categories_on_user_id_and_name')
      add_index :categories, [:user_id, :name], unique: true, name: 'index_categories_on_user_id_and_name'
    end
  end
  
  def down
    # Recreate the old index if rolling back
    unless index_name_exists?(:categories, 'idx_16548_index_categories_on_name')
      add_index :categories, :name, unique: true, name: 'idx_16548_index_categories_on_name'
    end
  end
end
