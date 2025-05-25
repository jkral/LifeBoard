class CreateSubcategories < ActiveRecord::Migration[7.0]
  def change
    create_table :subcategories do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :description
      t.decimal :score, precision: 3, scale: 1, default: 1.0
      t.integer :position, null: false

      t.timestamps
    end
    
    add_index :subcategories, [:category_id, :name], unique: true
    add_index :subcategories, [:category_id, :position], unique: true
  end
end
