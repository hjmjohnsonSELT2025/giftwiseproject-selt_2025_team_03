require 'rails_helper'

RSpec.describe ToolCall, type: :model do
    let(:user) { User.create!(first_name: "Al", last_name: "Bert", email: "test@example.com", username: "birdman", password: "password", password_confirmation: "password") }
end