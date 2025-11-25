# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
USERS = [
  {
    :username => "test",
    :email => "email@email.com",
    :first_name => "ruby",
    :last_name => "rails",
    :password => "password123",
    :password_confirmation => "password123"
  }
]
# assuming each user only has one email
USERS.each do |attrs|
    user = User.find_or_create_by!(:email => attrs[:email]) do |u|
      u.assign_attributes(attrs)
    end
    puts "Seeded user id=#{user.id} username=#{user.username}"
end
