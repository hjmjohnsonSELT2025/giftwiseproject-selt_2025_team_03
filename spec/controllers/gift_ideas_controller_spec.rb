require 'rails_helper'

RSpec.describe GiftIdeasController, type: :controller do
    let(:user) { User.create!(first_name: "Al", last_name: "Bert", email: "test@example.com", username: "birdman", password: "password", password_confirmation: "password") }
    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    describe 'GET list' do
      it 'shows list page' do
        get :list
        expect(response).to be_successful
      end
    end

    describe 'GET add' do
      it 'shows add page' do
        get :add
        expect(response).to be_successful
      end
    end

    #describe 'POST add' do
    #  it 'creates new user' do
    #    expect {
    #      post :add, params: {
    #        gift_idea: {
    #          title: 'excitingGift',
    #          price: 20,
    #          status: 'idea',
    #          url: 'http://shopping.com',
    #          notes: 'It better be a good gift',
    #          event_recipient_id: 1
    #        }
    #      }
    #    }.to change(GiftIdea, :count).by(1)
    #  end

    #  it 'renders after gift creation' do
    #    post :add, params: {
    #      gift_idea: {
    #        title: 'excitingGift',
    #        price: 20,
    #        status: 'idea',
    #        url: 'http://shopping.com',
    #        notes: 'It better be a good gift',
    #        event_recipient_id: 1
    #      }
    #    }
    #    expect(response).to render_template(gift_ideas_path)
    #    expect(flash[:notice]).to eq('excitingGift added!')
    #  end
    #end
end