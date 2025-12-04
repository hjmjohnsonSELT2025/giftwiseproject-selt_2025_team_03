require 'rails_helper'

RSpec.describe RecipientsController, type: :controller do
  let(:user) do
    User.create(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      first_name: 'Test',
      last_name: 'User'
    )
  end

  before do
    session[:user_id] = user.id
  end

  describe 'GET index' do
    it 'shows recipients page' do
      get :index
      expect(response).to be_successful
    end

    it 'loads recipients ordered by name' do
      user.recipients.create(name: 'Zoe')
      user.recipients.create(name: 'Alice')
      get :index
      expect(assigns(:recipients).first.name).to eq('Alice')
    end
  end

  describe 'GET search' do
    before do
      user.recipients.create(name: 'Mom', likes: 'gardening')
      user.recipients.create(name: 'Dad', likes: 'golf')
    end

    it 'finds recipients by name' do
      get :search, params: { query: 'mom' }
      json = JSON.parse(response.body)
      expect(json['recipients'].count).to eq(1)
    end

    it 'returns all recipients when query is empty' do
      get :search, params: { query: '' }
      json = JSON.parse(response.body)
      expect(json['recipients'].count).to eq(2)
    end

    it 'is case insensitive' do
      get :search, params: { query: 'MOM' }
      json = JSON.parse(response.body)
      expect(json['recipients'].count).to eq(1)
    end
  end
  #
  # describe 'GET new' do
  #   it 'shows new recipient form' do
  #     get :new
  #     expect(response).to be_successful
  #   end
  # end
  #
  # describe 'POST create' do
  #   it 'creates new recipient' do
  #     expect {
  #       post :create, params: {
  #         recipient: {
  #           name: 'Sister',
  #           likes: 'books',
  #           relationship: 'sibling'
  #         }
  #       }
  #     }.to change(Recipient, :count).by(1)
  #   end
  #
  #   it 'redirects after creation' do
  #     post :create, params: {
  #       recipient: { name: 'Sister' }
  #     }
  #     expect(response).to redirect_to(recipients_path)
  #   end
  #
  #   it 'rejects invalid recipient' do
  #     expect {
  #       post :create, params: {
  #         recipient: { name: '' }
  #       }
  #     }.not_to change(Recipient, :count)
  #   end
  # end
  #
  # describe 'DELETE destroy' do
  #   it 'deletes recipient' do
  #     recipient = user.recipients.create(name: 'Mom')
  #     expect {
  #       delete :destroy, params: { id: recipient.id }
  #     }.to change(Recipient, :count).by(-1)
  #   end
  # end
end