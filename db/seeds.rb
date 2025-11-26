# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
<<<<<<< HEAD
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
=======

# test user
user = User.find_or_create_by!(email: "johndoe@gmail.com") do |u|
  u.username = "JohnDoe"
  u.password = "password"
  u.password_confirmation = "password"
  u.first_name = "John"
  u.last_name = "Doe"
  u.birthday = Date.new(2003, 1, 1)
  puts "Created test user"
end

# Find or create events
christmas = Event.find_or_create_by!(user: user, name: "Christmas") do |e|
  e.date = Date.new(2025, 12, 25)
  e.budget = 1000
  e.location = "Home"
  e.theme = "Family Christmas"
  puts "Created Christmas event"
end

mom_birthday = Event.find_or_create_by!(user: user, name: "Mom's birthday") do |e|
  e.date = Date.new(2026, 2, 1)
  e.budget = 150
  e.location = "Restaurant"
  e.theme = "50th Birthday Party"
  puts "Created Mom's birthday event"
end

baby_shower = Event.find_or_create_by!(user: user, name: "Jane's Baby shower") do |e|
  e.date = Date.new(2026, 3, 1)
  e.budget = 100
  e.theme = "Baby Boy"
  puts "Created Baby shower event"
end

# Find or create recipients
dad = Recipient.find_or_create_by!(user: user, name: "Dad") do |r|
  r.age = 51
  r.likes = "Golf, football, lawn care, movies"
  r.dislikes = "Technology, books"
  puts "Created Dad recipient"
end

mom = Recipient.find_or_create_by!(user: user, name: "Mom") do |r|
  r.age = 50
  r.likes = "Jewelry, family time, gardening, plants"
  r.dislikes = "Sports, disorganization"
  puts "Created Mom recipient"
end

jane = Recipient.find_or_create_by!(user: user, name: "Jane") do |r|
  r.age = 22
  r.likes = "Vintage items, books, traveling"
  r.dislikes = "Sports, movies, boardgames"
  puts "Created Jane recipient"
end

# Find or create event-recipient connections
er_christmas_dad = EventRecipient.find_or_create_by!(event: christmas, recipient: dad) do |er|
  er.budget = 150
end

er_christmas_mom = EventRecipient.find_or_create_by!(event: christmas, recipient: mom) do |er|
  er.budget = 200
end

er_baby_shower_jane = EventRecipient.find_or_create_by!(event: baby_shower, recipient: jane) do |er|
  er.budget = 100
end

er_mom_birthday = EventRecipient.find_or_create_by!(event: mom_birthday, recipient: mom) do |er|
  er.budget = 150
end

# Find or create gift ideas
GiftIdea.find_or_create_by!(event_recipient: er_christmas_dad, title: "Golf Club") do |g|
  g.price = 120
  g.status = "purchased"
  g.url = "https://golf"
end

GiftIdea.find_or_create_by!(event_recipient: er_christmas_mom, title: "Crockpot") do |g|
  g.price = 120
  g.status = "idea"
  g.url = "https://crockpot"
end

GiftIdea.find_or_create_by!(event_recipient: er_baby_shower_jane, title: "Baby Boy Clothes") do |g|
  g.price = 40
  g.status = "backlogged"
  g.url = "https://babies"
end

GiftIdea.find_or_create_by!(event_recipient: er_mom_birthday, title: "Gold Necklace") do |g|
  g.price = 120
  g.status = "purchased"
end

puts "Seed completed"
puts "Test user login: johndoe@gmail.com / password"
puts "Total users: #{User.count}"
>>>>>>> origin/blake-app
