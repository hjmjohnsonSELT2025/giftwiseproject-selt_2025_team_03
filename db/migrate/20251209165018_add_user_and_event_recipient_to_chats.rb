class AddUserAndEventRecipientToChats < ActiveRecord::Migration[7.1]
  def change
    add_reference :chats, :user, null: false, foreign_key: true
    add_reference :chats, :event_recipient, null: false, foreign_key: true
  end
end
