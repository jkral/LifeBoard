# test_scores.rb
require_relative 'config/environment'

def display_scores
  puts "\n=== CURRENT SCORES ==="
  
  # Show total score (average of all categories)
  total = (Category.average(:score) || 0).round(1)
  puts "\nTOTAL SCORE: #{total}/10.0"
  
  # Show each category and its subcategories
  Category.all.includes(:subcategories).order(:position).each do |category|
    puts "\n#{category.name} (#{category.score.round(1)}/10.0)"
    category.subcategories.order(:position).each do |sub|
      puts "  - #{sub.name}: #{sub.score.round(1)}/10.0"
    end
  end
end

# Initial state
puts "=== INITIAL STATE ==="
display_scores

# Update some subcategory scores with more realistic values
puts "\n\n=== UPDATING SOME SUBCATEGORY SCORES ==="

# Health subcategories
Category.find_by(name: 'Health').subcategories.each_with_index do |sub, i|
  scores = [7.5, 8.0, 6.5]  # Mental, Physical, Spiritual
  puts "Setting #{sub.name} to #{scores[i]}"
  sub.update(score: scores[i])
end

# Personal subcategories
personal_subs = Category.find_by(name: 'Personal').subcategories.order(:position)
[9.0, 7.0, 8.5].each_with_index do |score, i|
  puts "Setting #{personal_subs[i].name} to #{score}"
  personal_subs[i].update(score: score)
end

# Professional subcategories
pro_subs = Category.find_by(name: 'Professional').subcategories.order(:position)
[7.0, 8.5, 9.0].each_with_index do |score, i|
  puts "Setting #{pro_subs[i].name} to #{score}"
  pro_subs[i].update(score: score)
end

# Show final state
puts "\n\n=== FINAL STATE ==="
display_scores

# Show how changing one subcategory affects the category and total
puts "\n\n=== DEMO: UPDATING A SINGLE SUBCATEGORY ==="
partner = Category.find_by(name: 'Personal').subcategories.find_by(name: 'Partner')
puts "Current Partner score: #{partner.score}"
puts "Updating Partner score from #{partner.score} to 5.0"
partner.update(score: 5.0)

# Show updated state
puts "\n=== UPDATED STATE ==="
display_scores
