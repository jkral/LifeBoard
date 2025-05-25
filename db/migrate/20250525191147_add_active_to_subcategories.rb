class AddActiveToSubcategories < ActiveRecord::Migration[8.0]
  def change
    add_column :subcategories, :active, :boolean
  end
end
