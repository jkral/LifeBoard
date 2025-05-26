class FixScorePrecisionIssue < ActiveRecord::Migration[8.0]
  def up
    # First, change the score columns to use integer type instead of decimal
    # This will store scores as integers (e.g., 100 instead of 10.0)
    change_column :categories, :score, :integer, default: 100
    change_column :subcategories, :score, :integer, default: 100
    
    # Update existing records to convert decimal scores to integers (multiply by 10)
    # Also ensure any null or low values are set to 100 (10.0)
    execute <<-SQL
      UPDATE categories SET score = CASE WHEN score IS NULL OR score < 10 THEN 100 ELSE score * 10 END;
      UPDATE subcategories SET score = CASE WHEN score IS NULL OR score < 10 THEN 100 ELSE score * 10 END;
    SQL
  end
  
  def down
    # Convert back to decimal if needed
    change_column :categories, :score, :decimal, precision: 5, scale: 2, default: 10.0
    change_column :subcategories, :score, :decimal, precision: 5, scale: 2, default: 10.0
    
    # Update existing records to convert integer scores back to decimals (divide by 10)
    execute <<-SQL
      UPDATE categories SET score = score / 10.0;
      UPDATE subcategories SET score = score / 10.0;
    SQL
  end
end
