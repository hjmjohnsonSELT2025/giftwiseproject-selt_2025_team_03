require 'rails_helper'

RSpec.describe ChatsController, type: :controller do
    let(:user) { User.create!(first_name: "Al", last_name: "Bert", email: "test@example.com", username: "birdman", password: "password", password_confirmation: "password") }
    let(:recipient) { Recipient.create!(name: "Ted", age: 25, likes: "Football, hiking", dislikes: "arts and crafts", birthday: "2000-12-01", relationship: "Friend", user_id:1) }
    let(:event) { Event.create!(name: "Christmas", date: "2025-12-25", budget: 20.0, location: "Home", theme: "Christmas", user_id:1) }
    before do
      allow(controller).to receive(:current_user).and_return(user)
      #allow(controller).to receive(:recipient).and_return(recipient)
      #allow(controller).to receive(:event).and_return(event)
    end

    describe 'POST query' do
        it 'obtains an LLM response with a valid query' do
    #        post :query, params: {
    #            input: "Please give me a gift rec for my friend Ted, who is 25 years old, likes: football and hiking, dislikes: arts and crafts. The event is Christmas at Home with a theme of Christmas and a budget of $20.00.",
    #            event_id: 1,
    #            recipient_id: 1
    #        }
    #        expect(session[:response]).not_to be_nil
        end

        it 'obtains a warning with an invalid query' do 
    #        post :query, params: {
    #            input: "",
    #            event_id: 1,
    #            recipient_id: 1
    #        }
    #        expect(flash[:alert]).to eq('Warning: query was empty')
        end
    end
end