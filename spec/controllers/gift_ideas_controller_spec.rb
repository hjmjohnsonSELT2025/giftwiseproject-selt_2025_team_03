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

  let(:other_user) do
    User.create!(
      username: 'jane.doe',
      email: 'jane.doe@example.com',
      password: 'password123',
      first_name: 'Jane',
      last_name: 'Doe'
    )
  end

  let(:event) { user.events.create!(name: 'Annual Holiday Exchange', date: Date.new(2025, 12, 24), budget: 500.00) }
  let(:recipient) { user.recipients.create!(name: 'Jane Doe (Wife)') }
  let(:event_recipient) { event.event_recipients.create!(recipient: recipient, budget: 150.00) }
  let!(:gift) { user.gift_ideas.create!(event_recipient: event_recipient, title: 'Original Item', price: 50.00) }

  before do
    session[:user_id] = user.id
  end

  describe 'Authentication and Authorization' do
    shared_examples 'requires login' do |method, action, params = {}|
      before { session[:user_id] = nil }
      it "redirects #{method.to_s.upcase} #{action} to login page" do
        send(method, action, params: params.merge(id: gift.id))
        expect(response).to redirect_to(login_path)
      end
    end

    include_examples 'requires login', :get, :index, {}
    include_examples 'requires login', :get, :new, {}
    include_examples 'requires login', :post, :create, { gift_idea: { title: 'T', event_recipient_id: 1 } }
    include_examples 'requires login', :get, :show, {}
    include_examples 'requires login', :get, :edit, {}
    include_examples 'requires login', :patch, :update, { gift_idea: { title: 'U' } }
    include_examples 'requires login', :delete, :destroy, {}

    # 🟢 FIXED TEST: Expecting HTTP status code 404 instead of the exception.
    it "prevents accessing other users' gifts by returning 404" do
      other_event = other_user.events.create!(name: 'Party', date: Date.today)
      other_recipient = other_user.recipients.create!(name: 'Friend')
      other_er = other_event.event_recipients.create!(recipient: other_recipient)
      other_gift = other_user.gift_ideas.create!(event_recipient: other_er, title: 'Secret Gift', price: 50)

      # Ensure user is logged in for the authorization check to be hit
      session[:user_id] = user.id

      # Execute the action
      get :show, params: { id: other_gift.id }

      # Expect the application's final response for unauthorized access, which
      # is typically handled as a 404 Not Found response when the RecordNotFound is rescued.
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #index' do
    it 'returns successful, loads user\'s gifts, and orders by title' do
      gift_z = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Zebra Print Robe', price: 50)
      gift_a = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Apple Watch Band', price: 30)

      other_event = other_user.events.create!(name: 'Other Event', date: Date.today)
      other_er = other_event.event_recipients.create!(recipient: other_user.recipients.create!(name: 'Dad'))
      other_gift = other_user.gift_ideas.create!(event_recipient: other_er, title: 'New Drill Set', price: 100.00)

      get :index

      expect(response).to be_successful
      expect(assigns(:gift_ideas)).to include(gift_z, gift_a)
      expect(assigns(:gift_ideas)).not_to include(other_gift)
      expect(assigns(:gift_ideas).map(&:title)).to eq(['Apple Watch Band', 'Original Item', 'Zebra Print Robe'])
    end

    it 'filters by query parameter' do
      gift2 = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Red Hat', price: 30)

      get :index, params: { query: 'original' }

      expect(assigns(:gift_ideas)).to include(gift)
      expect(assigns(:gift_ideas)).not_to include(gift2)
    end
  end

  describe 'GET #search (JSON API)' do
    it 'returns matching gifts by title (case insensitive) and includes event/recipient names' do
      get :search, params: { query: 'ORIGINAL' }, format: :json

      expect(response).to be_successful
      json = JSON.parse(response.body)
      gift_data = json['gift_ideas'][0]

      expect(json['gift_ideas'].length).to eq(1)
      expect(gift_data['title']).to eq('Original Item')
      expect(gift_data['event_recipient']['event_name']).to eq('Annual Holiday Exchange')
      expect(gift_data['event_recipient']['recipient_name']).to eq('Jane Doe (Wife)')
    end

    it 'returns all gifts when query is empty' do
      user.gift_ideas.create!(event_recipient: event_recipient, title: 'Gift 2', price: 30)
      get :search, params: { query: '' }, format: :json
      json = JSON.parse(response.body)
      expect(json['gift_ideas'].length).to eq(2)
    end
  end

  describe 'GET #show' do
    it 'shows gift idea details and loads associated objects' do
      get :show, params: { id: gift.id }

      expect(response).to be_successful
      expect(assigns(:gift_idea)).to eq(gift)
      expect(assigns(:event_recipient)).to eq(event_recipient)
    end
  end

  describe 'GET #new' do
    it 'shows new gift form, creates new object, and loads event recipients' do
      get :new

      expect(response).to be_successful
      expect(assigns(:gift_idea)).to be_a_new(GiftIdea)
      expect(assigns(:event_recipients)).to include(event_recipient)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      { title: 'Electric Blanket', price: 75.00, event_recipient_id: event_recipient.id }
    end

    it 'creates new gift idea, sets user/default status, and redirects' do
      expect {
        post :create, params: { gift_idea: valid_params }
      }.to change(GiftIdea, :count).by(1)

      created_gift = GiftIdea.last
      expect(created_gift.user).to eq(user)
      expect(created_gift.status).to eq('idea')
      expect(response).to redirect_to(gift_ideas_path)
      expect(flash[:notice]).to match(/Electric Blanket added/)
    end

    it 'renders form on validation error' do
      post :create, params: { gift_idea: { title: '', event_recipient_id: event_recipient.id } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new)
    end

    context 'Budget Validation' do
      before { event.update!(budget: 200) }
      let(:high_price_params) { valid_params.merge(price: 150, status: 'purchased') }

      it 'allows idea status gifts regardless of price' do
        expect {
          post :create, params: { gift_idea: valid_params.merge(price: 500, status: 'idea') }
        }.to change(GiftIdea, :count).by(1)
      end

      it 'rejects purchased gift exceeding recipient budget' do
        event_recipient.update!(budget: 50)
        post :create, params: { gift_idea: high_price_params }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to match(/exceeds.*budget/)
      end

      it 'rejects purchased gift exceeding event total budget' do
        event.update!(budget: 50)
        event_recipient.update!(budget: 500)
        post :create, params: { gift_idea: high_price_params }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to match(/exceeds.*budget/)
      end

      it 'considers existing purchased gifts in total budget calculation' do
        user.gift_ideas.create!(event_recipient: event_recipient, title: 'First Gift', price: 100, status: 'purchased')

        post :create, params: {
          gift_idea: valid_params.merge(price: 150, status: 'purchased')
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH #update' do
    let(:update_params) { { title: 'Updated Title', price: 75.50 } }

    it 'updates gift idea and redirects' do
      patch :update, params: { id: gift.id, gift_idea: update_params }
      gift.reload
      expect(gift.title).to eq('Updated Title')
      expect(gift.price).to eq(75.50)
      expect(response).to redirect_to(gift_ideas_path)
      expect(flash[:notice]).to match(/updated/)
    end

    it 'renders form on validation error' do
      patch :update, params: { id: gift.id, gift_idea: { title: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:edit)
    end

    it 'validates budget on update and excludes current gift from calculation' do
      event.update!(budget: 100)
      gift.update!(price: 60, status: 'purchased')

      # Test success (within budget)
      patch :update, params: { id: gift.id, gift_idea: { price: 80, status: 'purchased' } }
      expect(response).to redirect_to(gift_ideas_path)
      gift.reload
      expect(gift.price).to eq(80)

      # Test failure (exceeds budget)
      patch :update, params: { id: gift.id, gift_idea: { price: 150, status: 'purchased' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys gift idea and redirects for HTML' do
      gift_to_delete = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Item to Delete', price: 50)

      expect {
        delete :destroy, params: { id: gift_to_delete.id }
      }.to change(GiftIdea, :count).by(-1)

      expect(response).to redirect_to(gift_ideas_path)
    end

    it 'destroys gift idea and returns JSON success' do
      gift_to_delete = user.gift_ideas.create!(event_recipient: event_recipient, title: 'Item to Delete', price: 50)

      expect {
        delete :destroy, params: { id: gift_to_delete.id }, format: :json
      }.to change(GiftIdea, :count).by(-1)

      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json['success']).to be true
    end
  end
end