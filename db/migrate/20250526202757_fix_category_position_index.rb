class FixCategoryPositionIndex < ActiveRecord::Migration[8.0]
  def up
    # Remove the old unique index on position
    remove_index :categories, name: 'idx_16548_index_categories_on_position' if index_name_exists?(:categories, 'idx_16548_index_categories_on_position')
    
    # Add a new index that scopes position to user_id
    add_index :categories, [:user_id, :position], unique: true, name: 'index_categories_on_user_id_and_position'
  end
  
  def down
    # Remove the compound index
    remove_index :categories, name: 'index_categories_on_user_id_and_position' if index_name_exists?(:categories, 'index_categories_on_user_id_and_position')
    
    # Recreate the old index
    add_index :categories, :position, unique: true, name: 'idx_16548_index_categories_on_position'
  end
end
