class CreateGoals < ActiveRecord::Migration[8.0]
  def change
    create_table :goals do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: 'todo'
      t.integer :position, null: false
      t.references :category, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :goals, [:category_id, :status, :position]
    add_index :goals, [:user_id, :category_id, :status, :position]
  end
end
