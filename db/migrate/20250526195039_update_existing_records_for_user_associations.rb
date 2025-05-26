class UpdateExistingRecordsForUserAssociations < ActiveRecord::Migration[8.0]
  def up
    # Get the first user or create a default one if none exists
    user = User.first_or_create!(
      name: 'Default User',
      email_address: 'default@example.com',
      password: 'password',
      password_confirmation: 'password'
    )

    # Update all categories and subcategories to belong to this user
    execute "UPDATE categories SET user_id = #{user.id} WHERE user_id IS NULL"
    execute "UPDATE subcategories SET user_id = #{user.id} WHERE user_id IS NULL"
  end

  def down
    # This migration cannot be reversed as we can't determine which records belonged to which user
    raise ActiveRecord::IrreversibleMigration
  end
end
