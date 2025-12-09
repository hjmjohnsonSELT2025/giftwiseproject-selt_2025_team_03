class EventRecipient < ApplicationRecord
  belongs_to :event
  belongs_to :recipient
  has_many :gift_ideas, dependent: :destroy
  has_many :chats, dependent: :destroy

  validates :event_id, uniqueness: { scope: :recipient_id }
end
