# Test script to verify score calculations

# Print all categories and their subcategories with scores
puts "=== Current Categories and Subcategories ==="
Category.all.includes(:subcategories).each do |category|
  puts "\nCategory: #{category.name} (Score: #{category.score})"
  category.subcategories.each do |subcat|
    puts "  - #{subcat.name}: #{subcat.score}"
  end
end

# Test 1: Update some scores and verify category updates
puts "\n=== Updating Scores ==="

# Get the first category and its subcategories
category = Category.first
subcats = category.subcategories.order(:position)

# Update subcategory scores
subcats[0].update(score: 8.5)
subcats[1].update(score: 7.0)
subcats[2].update(score: 9.0)

# Reload to see updates
category.reload

puts "\nAfter updating #{category.name} subcategory scores:"
category.subcategories.each { |sc| puts "  - #{sc.name}: #{sc.score}" }
puts "  Category score: #{category.score} (should be average of subcategories)"

# Test 2: Update all categories and check total score
puts "\n=== Updating All Categories ==="

# Update all subcategories with random scores between 5.0 and 10.0
Category.all.each do |cat|
  cat.subcategories.each do |subcat|
    new_score = (5.0 + rand * 5.0).round(1)
    subcat.update(score: new_score)
  end
  cat.reload
  
  puts "\n#{cat.name}:"
  cat.subcategories.each { |sc| puts "  - #{sc.name}: #{sc.score}" }
  puts "  Category score: #{cat.score}"
end

# Calculate total score
total_score = (Category.average(:score) || 0).round(1)
puts "\n=== Total Score ==="
puts "Average of all category scores: #{total_score}"

puts "\nTest complete!"
