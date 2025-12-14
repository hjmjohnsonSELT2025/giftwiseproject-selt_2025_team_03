require 'rails_helper'

RSpec.describe RecipientsController, type: :controller do
  let(:user) do
    User.create!(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'Test',
      last_name: 'User'
    )
  end

  before do
    session[:user_id] = user.id
  end


  describe 'GET index' do
    it 'shows page, loads recipients ordered by name, and limits to current user' do
      other_user = User.create!(username: 'other', email: 'o@e.com', password: 'p', password_confirmation: 'p', first_name: 'O', last_name: 'U')
      other_recipient = other_user.recipients.create(name: 'Someone Else')
      user.recipients.create(name: 'Zoe')
      user.recipients.create(name: 'Alice')

      get :index

      expect(response).to be_successful
      expect(assigns(:recipients).count).to eq(2)
      expect(assigns(:recipients).first.name).to eq('Alice')
      expect(assigns(:recipients)).not_to include(other_recipient)
    end

    it 'filters by query parameter' do
      user.recipients.create(name: 'Mom', likes: 'gardening')
      user.recipients.create(name: 'Dad', likes: 'golf')

      get :index, params: { query: 'mom' }

      expect(assigns(:recipients).count).to eq(1)
      expect(assigns(:recipients).first.name).to eq('Mom')
    end
  end

  describe 'GET search' do
    before do
      user.recipients.create(name: 'Mom', likes: 'gardening')
      user.recipients.create(name: 'Dad', likes: 'golf')
    end

    it 'finds recipients, returns JSON, and is case insensitive' do
      get :search, params: { query: 'MOM' }, format: :json

      json = JSON.parse(response.body)
      expect(json['recipients'].length).to eq(1)
      expect(json['recipients'][0]['name']).to eq('Mom')
    end

    it 'returns all recipients when query is empty' do
      get :search, params: { query: '' }, format: :json

      json = JSON.parse(response.body)
      expect(json['recipients'].length).to eq(2)
    end
  end

  describe 'GET new' do
    let(:source_user) do
      User.create!(username: 'sourceuser', email: 's@e.com', password: 'p', password_confirmation: 'p',
                   first_name: 'Source', last_name: 'User', likes: 'reading, hiking') # Already had required fields
    end

    it 'shows form, creates object, and loads events' do
      user.events.create(name: 'Christmas', date: Date.today)
      get :new

      expect(response).to be_successful
      expect(assigns(:recipient)).to be_a_new(Recipient)
      expect(assigns(:events)).to be_present
    end

    it 'pre-fills data when copying from another user' do
      get :new, params: { user_id: source_user.id }

      recipient = assigns(:recipient)
      expect(recipient.name).to eq('Source User')
      expect(recipient.likes).to eq('reading, hiking')
      expect(recipient.relationship).to eq('Other')
    end
  end

  describe 'POST create' do
    let(:valid_params) { { name: 'Sister', likes: 'books', relationship: 'Sibling' } }

    it 'creates new recipient, associates it with user/events, and redirects' do
      event1 = user.events.create(name: 'Event', date: Date.today)

      expect {
        post :create, params: { recipient: valid_params.merge(event_ids: [event1.id]) }
      }.to change(Recipient, :count).by(1)

      recipient = Recipient.last
      expect(recipient.creator).to eq(user)
      expect(recipient.events).to include(event1)
      expect(response).to redirect_to(recipients_path)
    end

    it 'handles custom relationship text and normalizes blank fields' do
      post :create, params: {
        recipient: { name: 'Neighbor', relationship: 'Other', relationship_other: 'Close Neighbor', dislikes: '  ' }
      }
      recipient = Recipient.last
      expect(recipient.relationship_other).to eq('Close Neighbor')
      expect(recipient.dislikes).to be_nil
    end

    it 'rejects invalid recipient and enforces unique name per user' do
      user.recipients.create(name: 'Mom')

      expect { post :create, params: { recipient: { name: '' } } }.not_to change(Recipient, :count)

      expect { post :create, params: { recipient: { name: 'Mom' } } }.not_to change(Recipient, :count)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to match(/already in your recipient list/)
    end

    it 'allows same name for different users' do
      User.create!(username: 'other', email: 'o2@e.com', password: 'p', password_confirmation: 'p', first_name: 'O', last_name: 'U').recipients.create(name: 'Mom')

      expect {
        post :create, params: { recipient: { name: 'Dad' } }
      }.to change(Recipient, :count).by(1)
    end

    it 'sets visibility when user has public profile' do
      user.update(public_profile: true)
      post :create, params: { recipient: { name: 'Public Mom', visible: true } }
      expect(Recipient.last.visible).to be true
    end
  end

  describe 'PATCH update' do
    let(:recipient) { user.recipients.create(name: 'Mom', likes: 'books', dislikes: 'sports') }

    it 'updates recipient, associations, and redirects' do
      event2 = user.events.create(name: 'Birthday', date: Date.today)

      patch :update, params: {
        id: recipient.id,
        recipient: { name: 'Mother', likes: '', event_ids: [event2.id] }
      }

      recipient.reload
      expect(recipient.name).to eq('Mother')
      expect(recipient.likes).to be_nil # Check normalization
      expect(recipient.dislikes).to eq('sports') # Check untouched field
      expect(recipient.events.to_a).to contain_exactly(event2)
      expect(response).to redirect_to(recipients_path)
    end

    it 'toggles visibility' do
      patch :update, params: { id: recipient.id, recipient: { visible: true } }
      recipient.reload
      expect(recipient.visible).to be true
    end

    it 'renders form on validation error' do
      patch :update, params: { id: recipient.id, recipient: { name: '' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:edit)
    end
  end

  # --- DELETE ---

  describe 'DELETE destroy' do
    let!(:recipient) do
      r = user.recipients.create(name: 'Mom')
      r.events << user.events.create(name: 'Christmas', date: Date.today)
      r
    end

    it 'deletes recipient, associated event_recipients, and redirects for HTML' do
      expect {
        delete :destroy, params: { id: recipient.id }
      }.to change(Recipient, :count).by(-1)
                                    .and change(EventRecipient, :count).by(-1)

      expect(response).to redirect_to(recipients_path)
    end

    it 'returns JSON for JSON format' do
      delete :destroy, params: { id: recipient.id }, format: :json

      expect(response).to be_successful
      expect(JSON.parse(response.body)['success']).to be true
    end
  end

  describe 'authorization' do
    it 'requires login for index' do
      session[:user_id] = nil
      get :index
      expect(response).to redirect_to(login_path)
    end

    it 'prevents accessing other users recipients' do
      other_user = User.create!(username: 'other', email: 'o@e.com', password: 'p', password_confirmation: 'p', first_name: 'O', last_name: 'U')
      other_recipient = other_user.recipients.create(name: 'Someone')

      expect {
        get :edit, params: { id: other_recipient.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end