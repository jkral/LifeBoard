class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :description
      t.decimal :score, precision: 3, scale: 1, default: 1.0
      t.integer :position, null: false

      t.timestamps
    end
    
    add_index :categories, :name, unique: true
    add_index :categories, :position, unique: true
  end
end
