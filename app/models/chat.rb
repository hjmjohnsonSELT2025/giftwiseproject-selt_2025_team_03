class Chat < ApplicationRecord
  acts_as_chat messages_foreign_key: :chat_id

  belongs_to :user
  belongs_to :event_recipient, optional:true

  validates :user, presence: true
end
