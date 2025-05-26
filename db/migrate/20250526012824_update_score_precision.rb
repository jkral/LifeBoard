class UpdateScorePrecision < ActiveRecord::Migration[8.0]
  def change
    # Increase precision for category scores
    change_column :categories, :score, :decimal, precision: 5, scale: 2, default: 10.0
    
    # Increase precision for subcategory scores
    change_column :subcategories, :score, :decimal, precision: 5, scale: 2, default: 10.0
  end
end
