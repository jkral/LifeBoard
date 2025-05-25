namespace :db do
  desc 'Load sample data into the database'
  task sample_data: :environment do
    puts 'Loading sample data...'
    
    # Clear existing data
    Category.destroy_all
    
    # Create Categories
    health = Category.create!(
      name: 'Health',
      description: 'Physical & Mental Wellness',
      position: 1,
      score: 7.5
    )
    
    personal = Category.create!(
      name: 'Personal',
      description: 'Relationships & Growth',
      position: 2,
      score: 6.8
    )
    
    professional = Category.create!(
      name: 'Professional',
      description: 'Career & Skills',
      position: 3,
      score: 7.1
    )
    
    # Create Subcategories for Health
    Subcategory.create!([
      {
        category: health,
        name: 'Physical',
        description: 'Exercise & Nutrition',
        position: 1,
        score: 7.8,
        active: true
      },
      {
        category: health,
        name: 'Mental',
        description: 'Mindfulness & Stress',
        position: 2,
        score: 7.2,
        active: true
      }
    ])
    
    # Create Subcategories for Personal
    Subcategory.create!([
      {
        category: personal,
        name: 'Relationships',
        description: 'Family & Friends',
        position: 1,
        score: 7.0,
        active: true
      },
      {
        category: personal,
        name: 'Growth',
        description: 'Learning & Development',
        position: 2,
        score: 6.5,
        active: true
      }
    ])
    
    # Create Subcategories for Professional
    Subcategory.create!([
      {
        category: professional,
        name: 'Career',
        description: 'Job & Growth',
        position: 1,
        score: 7.3,
        active: true
      },
      {
        category: professional,
        name: 'Skills',
        description: 'Learning & Development',
        position: 2,
        score: 6.9,
        active: true
      }
    ])
    
    puts 'Sample data loaded successfully!'
  end
end
