# test_scores.rb
require_relative 'config/environment'

def display_scores(show_inactive: false)
  puts "\n=== CURRENT SCORES ==="
  
  # Show total score (average of all categories)
  total = (Category.average(:score) || 0).round(1)
  puts "\nTOTAL SCORE: #{total}/10.0"
  
  # Show each category and its subcategories
  Category.all.includes(:subcategories).order(:position).each do |category|
    puts "\n#{category.name} (#{category.score.round(1)}/10.0)"
    category.subcategories.order(:position).each do |sub|
      status = sub.active ? '' : ' [INACTIVE]'
      puts "  - #{sub.name}: #{sub.score.round(1)}/10.0#{status}"
    end
  end
  
  if show_inactive
    puts "\nActive subcategories only:"
    Category.all.includes(:subcategories).order(:position).each do |category|
      active_subs = category.active_subcategories
      next if active_subs.empty?
      
      puts "\n#{category.name} (from #{active_subs.count} active subcategories):"
      active_subs.each do |sub|
        puts "  - #{sub.name}: #{sub.score.round(1)}/10.0"
      end
      
      calculated_avg = (active_subs.sum(:score) / active_subs.count.to_f).round(1)
      puts "  Calculated average: #{calculated_avg} (should match category score: #{category.score.round(1)})"
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

# Show state after initial updates
puts "\n\n=== AFTER INITIAL UPDATES ==="
display_scores(show_inactive: true)

# Test deactivating a subcategory
puts "\n\n=== TESTING INACTIVE SUBCATEGORIES ==="

# Deactivate the Spiritual subcategory
spiritual = Category.find_by(name: 'Health').subcategories.find_by(name: 'Spiritual')
puts "Deactivating #{spiritual.name} subcategory"
spiritual.update(active: false)

# Show how this affects the Health category
health = Category.find_by(name: 'Health')
health.reload
active_names = health.active_subcategories.map(&:name).join(', ')
puts "\nAfter deactivating #{spiritual.name}:"
puts "- Active subcategories: #{active_names}"
puts "- Health score is now: #{health.score} (average of active subcategories only)"

# Show final state with inactive indicators
puts "\n=== FINAL STATE (SHOWING INACTIVE) ==="
display_scores(show_inactive: true)

# Reactivate and test
puts "\n\n=== TESTING REACTIVATION ==="
spiritual.update(active: true)
health.reload
puts "Reactivated #{spiritual.name} subcategory"
puts "- Health score is now: #{health.score} (back to average of all subcategories)"

# Show final state
puts "\n=== FINAL STATE (ALL ACTIVE) ==="
display_scores(show_inactive: true)
