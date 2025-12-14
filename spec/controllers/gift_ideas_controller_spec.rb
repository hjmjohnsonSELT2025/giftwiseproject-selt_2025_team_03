require 'rails_helper'

RSpec.describe GiftIdeasController, type: :controller do
  let(:user) do
    User.create!(
      first_name: "John",
      last_name: "Doe",
      email: "john.doe@example.com",
      username: "johndoe",
      password: "password",
      password_confirmation: "password"
    )
  end

  let(:event) { user.events.create!(name: 'Annual Holiday Exchange', date: Date.new(2025, 12, 24), budget: 500.00) }
  let(:recipient) { user.recipients.create!(name: 'Jane Doe (Wife)') }
  let(:event_recipient) { event.event_recipients.create!(recipient: recipient, budget: 150.00) }

  before do
    session[:user_id] = user.id
  end

  describe 'GET index' do
    it 'shows gift ideas page' do
      get :index
      expect(response).to be_successful
    end

    it 'loads gift ideas for current user' do
      gift1 = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Cashmere Scarf', price: 95.00)
      gift2 = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Book: The Martian', price: 12.50)

      get :index
      expect(assigns(:gift_ideas)).to include(gift1, gift2)
    end

    it 'does not show other users gift ideas' do
      other_user = User.create!(
        username: 'jane.doe',
        email: 'jane.doe@example.com',
        password: 'password123',
        first_name: 'Jane',
        last_name: 'Doe'
      )
      other_event = other_user.events.create!(name: 'Jane’s Birthday', date: Date.new(2025, 7, 10))
      other_recipient = other_user.recipients.create!(name: 'Dad')
      other_er = other_event.event_recipients.create!(recipient: other_recipient)
      other_gift = other_user.gift_ideas.create!(event_recipient: other_er, title: 'New Drill Set', price: 100.00)

      get :index
      expect(assigns(:gift_ideas)).not_to include(other_gift)
    end

    it 'filters by query parameter' do
      gift1 = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Cashmere Scarf', price: 50)
      gift2 = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Red Hat', price: 30)

      get :index, params: { query: 'cashmere' }

      expect(assigns(:gift_ideas)).to include(gift1)
      expect(assigns(:gift_ideas)).not_to include(gift2)
    end

    it 'orders by title' do
      gift_z = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Zebra Print Robe', price: 50)
      gift_a = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Apple Watch Band', price: 30)

      get :index

      expect(assigns(:gift_ideas).first).to eq(gift_a)
      expect(assigns(:gift_ideas).last).to eq(gift_z)
    end
  end

  describe 'GET search' do
    it 'returns JSON response' do
      user.gift_ideas.create!(event_recipient: event_recipient, title: 'Silk Scarf', price: 50)

      get :search, params: { query: 'silk' }, format: :json

      expect(response).to be_successful
      expect(response.content_type).to include('application/json')
    end

    it 'searches by title case insensitively' do
      gift = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Travel Mug', price: 50)

      get :search, params: { query: 'MUG' }, format: :json

      json = JSON.parse(response.body)
      expect(json['gift_ideas'].length).to eq(1)
      expect(json['gift_ideas'][0]['title']).to eq('Travel Mug')
    end

    it 'returns all gifts when query is empty' do
      user.gift_ideas.create!(event_recipient: event_recipient, title: 'Gift 1', price: 50)
      user.gift_ideas.create!(event_recipient: event_recipient, title: 'Gift 2', price: 30)

      get :search, params: { query: '' }, format: :json

      json = JSON.parse(response.body)
      expect(json['gift_ideas'].length).to eq(2)
    end

    it 'includes event and recipient information' do
      gift = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Coffee Maker', price: 50)

      get :search, params: { query: 'coffee' }, format: :json

      json = JSON.parse(response.body)
      gift_data = json['gift_ideas'][0]

      expect(gift_data['event_recipient']['event_name']).to eq('Annual Holiday Exchange')
      expect(gift_data['event_recipient']['recipient_name']).to eq('Jane Doe (Wife)')
    end
  end

  describe 'GET show' do
    it 'shows gift idea details' do
      gift = user.gift_ideas.create!(event_recipient: event_recipient, title: 'New Shoes', price: 120.00)

      get :show, params: { id: gift.id }

      expect(response).to be_successful
      expect(assigns(:gift_idea)).to eq(gift)
      expect(assigns(:event_recipient)).to eq(event_recipient)
    end
  end

  describe 'GET new' do
    it 'shows new gift form' do
      get :new
      expect(response).to be_successful
    end

    it 'creates new gift object' do
      get :new
      expect(assigns(:gift_idea)).to be_a_new(GiftIdea)
    end

    it 'loads available event recipients' do
      get :new
      expect(assigns(:event_recipients)).to include(event_recipient)
    end
  end

  describe 'POST create' do
    it 'creates new gift idea' do
      expect {
        post :create, params: {
          gift_idea: {
            title: 'Electric Blanket',
            price: 75.00,
            status: 'idea',
            event_recipient_id: event_recipient.id
          }
        }
      }.to change(GiftIdea, :count).by(1)
    end

    it 'redirects after successful creation' do
      post :create, params: {
        gift_idea: {
          title: 'Electric Blanket',
          price: 75.00,
          event_recipient_id: event_recipient.id
        }
      }

      expect(response).to redirect_to(gift_ideas_path)
      expect(flash[:notice]).to match(/Electric Blanket added/)
    end

    it 'renders form on validation error' do
      post :create, params: {
        gift_idea: {
          title: '',
          event_recipient_id: event_recipient.id
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new)
    end

    it 'sets default status to idea' do
      post :create, params: {
        gift_idea: {
          title: 'Gift',
          event_recipient_id: event_recipient.id
        }
      }

      gift = GiftIdea.last
      expect(gift.status).to eq('idea')
    end

    it 'associates gift with current user' do
      post :create, params: {
        gift_idea: {
          title: 'Gift',
          event_recipient_id: event_recipient.id
        }
      }

      gift = GiftIdea.last
      expect(gift.user).to eq(user)
    end

    context 'budget validation' do
      it 'rejects gift exceeding event budget' do
        event.update!(budget: 100)

        post :create, params: {
          gift_idea: {
            title: 'Expensive Art',
            price: 150,
            status: 'purchased',
            event_recipient_id: event_recipient.id
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to match(/exceeds.*budget/)
      end

      it 'rejects gift exceeding recipient budget' do
        event_recipient.update!(budget: 50)

        post :create, params: {
          gift_idea: {
            title: 'Over Budget Watch',
            price: 75,
            status: 'purchased',
            event_recipient_id: event_recipient.id
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to match(/exceeds.*budget/)
      end

      it 'allows gift within budget' do
        event.update!(budget: 200)

        expect {
          post :create, params: {
            gift_idea: {
              title: 'Within Budget Item',
              price: 50,
              status: 'purchased',
              event_recipient_id: event_recipient.id
            }
          }
        }.to change(GiftIdea, :count).by(1)
      end

      it 'does not validate budget for non-purchased gifts' do
        event.update!(budget: 100)

        expect {
          post :create, params: {
            gift_idea: {
              title: 'Just an Idea (High Price)',
              price: 150,
              status: 'idea',
              event_recipient_id: event_recipient.id
            }
          }
        }.to change(GiftIdea, :count).by(1)
      end

      it 'considers existing purchases when validating budget' do
        event.update!(budget: 200)
        user.gift_ideas.create!(
          event_recipient: event_recipient,
          title: 'First Purchased Gift',
          price: 100,
          status: 'purchased'
        )

        post :create, params: {
          gift_idea: {
            title: 'Second Gift (Too Much)',
            price: 150,
            status: 'purchased',
            event_recipient_id: event_recipient.id
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET edit' do
    it 'shows edit form' do
      gift = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Gift to Edit', price: 50)

      get :edit, params: { id: gift.id }

      expect(response).to be_successful
      expect(assigns(:gift_idea)).to eq(gift)
    end

    it 'loads event recipients' do
      gift = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Gift', price: 50)

      get :edit, params: { id: gift.id }

      expect(assigns(:event_recipients)).to be_present
    end
  end

  describe 'PATCH update' do
    let(:gift) { user.gift_ideas.create!(event_recipient: event_recipient, title: 'Original Item', price: 50) }

    it 'updates gift idea' do
      patch :update, params: {
        id: gift.id,
        gift_idea: {
          title: 'Updated Title',
          price: 75.50
        }
      }

      gift.reload
      expect(gift.title).to eq('Updated Title')
      expect(gift.price).to eq(75.50)
    end

    it 'redirects after successful update' do
      patch :update, params: {
        id: gift.id,
        gift_idea: { title: 'Updated' }
      }

      expect(response).to redirect_to(gift_ideas_path)
      expect(flash[:notice]).to match(/updated/)
    end

    it 'renders form on validation error' do
      patch :update, params: {
        id: gift.id,
        gift_idea: { title: '' }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:edit)
    end

    it 'validates budget on update' do
      event.update!(budget: 100)

      patch :update, params: {
        id: gift.id,
        gift_idea: {
          price: 150,
          status: 'purchased'
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'excludes current gift from budget calculation' do
      event.update!(budget: 100)
      gift.update!(price: 60, status: 'purchased')

      patch :update, params: {
        id: gift.id,
        gift_idea: { price: 80, status: 'purchased' }
      }

      expect(response).to redirect_to(gift_ideas_path)
      gift.reload
      expect(gift.price).to eq(80)
    end
  end

  describe 'DELETE destroy' do
    it 'destroys gift idea' do
      gift = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Item to Delete', price: 50)

      expect {
        delete :destroy, params: { id: gift.id }
      }.to change(GiftIdea, :count).by(-1)
    end

    it 'redirects to index for HTML' do
      gift = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Item to Delete', price: 50)

      delete :destroy, params: { id: gift.id }

      expect(response).to redirect_to(gift_ideas_path)
    end

    it 'returns JSON for JSON format' do
      gift = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Item to Delete', price: 50)

      delete :destroy, params: { id: gift.id }, format: :json

      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json['success']).to be true
    end
  end

  describe 'authorization' do
    it 'requires login for index' do
      session[:user_id] = nil
      get :index
      expect(response).to redirect_to(login_path)
    end

    it 'prevents accessing other users gifts' do
      other_user = User.create!(
        username: 'other.doe',
        email: 'other.doe@example.com',
        password: 'password',
        first_name: 'Other',
        last_name: 'Doe'
      )
      other_event = other_user.events.create!(name: 'Party', date: Date.today)
      other_recipient = other_user.recipients.create!(name: 'Friend')
      other_er = other_event.event_recipients.create!(recipient: other_recipient)
      other_gift = other_user.gift_ideas.create!(event_recipient: other_er, title: 'Secret Gift', price: 50)

      expect {
        get :show, params: { id: other_gift.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end