# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create a test user if one doesn't exist
user = User.find_or_create_by!(email_address: 'test@example.com') do |u|
  u.name = 'Test User'
  u.password = 'password'
  u.password_confirmation = 'password'
end

# Clear existing categories
user.categories.destroy_all

# Define our three main categories with their subcategories
categories = [
  {
    name: 'Health',
    position: 1,
    subcategories: [
      { name: 'Mental', position: 1, active: true },
      { name: 'Physical', position: 2, active: true },
      { name: 'Spiritual', position: 3, active: true }
    ]
  },
  {
    name: 'Personal',
    position: 2,
    subcategories: [
      { name: 'Partner', position: 1, active: true },
      { name: 'Family', position: 2, active: true },
      { name: 'Social', position: 3, active: true }
    ]
  },
  {
    name: 'Professional',
    position: 3,
    subcategories: [
      { name: 'Work', position: 1, active: true },
      { name: 'Education', position: 2, active: true },
      { name: 'Passion', position: 3, active: true }
    ]
  }
]

# Create categories and subcategories
categories.each do |cat_attrs|
  # Create a copy of the hash to avoid modifying the original
  cat_attrs_copy = cat_attrs.dup
  subcategories = cat_attrs_copy.delete(:subcategories) || []
  
  category = user.categories.create!(cat_attrs_copy.merge(score: 10.0))
  
  subcategories.each do |sub_attrs|
    category.subcategories.create!(sub_attrs.merge(score: 10.0, user_id: user.id))
  end
end

puts "Created user: test@example.com / password"
