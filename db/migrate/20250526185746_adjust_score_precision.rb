class AdjustScorePrecision < ActiveRecord::Migration[8.0]
  def up
    change_column :categories, :score, :decimal, precision: 5, scale: 2, default: 10.0
    change_column :subcategories, :score, :decimal, precision: 5, scale: 2, default: 10.0
  end

  def down
    change_column :categories, :score, :decimal, precision: 3, scale: 1, default: 10.0
    change_column :subcategories, :score, :decimal, precision: 3, scale: 1, default: 10.0
  end
end
