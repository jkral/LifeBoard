class SetDefaultActiveForSubcategories < ActiveRecord::Migration[7.0]
  def up
    # Set all existing subcategories to active
    Subcategory.update_all(active: true)
    
    # Change the column to not allow null and set default to true
    change_column_default :subcategories, :active, true
    change_column_null :subcategories, :active, false
  end

  def down
    change_column_null :subcategories, :active, true
    change_column_default :subcategories, :active, nil
  end
end
