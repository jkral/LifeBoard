class ResetScoresToDecimal < ActiveRecord::Migration[8.0]
  def up
    # First convert any existing integer scores back to decimals
    execute <<-SQL
      UPDATE categories SET score = score / 10.0 WHERE score > 10;
      UPDATE subcategories SET score = score / 10.0 WHERE score > 10;
    SQL
    
    # Change the columns back to decimal with proper precision
    change_column :categories, :score, :decimal, precision: 3, scale: 1, default: 10.0
    change_column :subcategories, :score, :decimal, precision: 3, scale: 1, default: 10.0
    
    # Make sure all scores are properly set to 10.0 by default
    execute <<-SQL
      UPDATE categories SET score = 10.0 WHERE score IS NULL OR score < 1.0;
      UPDATE subcategories SET score = 10.0 WHERE score IS NULL OR score < 1.0;
    SQL
  end
  
  def down
    change_column :categories, :score, :integer, default: 100
    change_column :subcategories, :score, :integer, default: 100
    
    execute <<-SQL
      UPDATE categories SET score = score * 10;
      UPDATE subcategories SET score = score * 10;
    SQL
  end
end
