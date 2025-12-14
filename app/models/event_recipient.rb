class EventRecipient < ApplicationRecord
  belongs_to :event
  belongs_to :recipient

  has_many :gift_ideas, dependent: :destroy

  validates :event, presence: true
  validates :recipient, presence: true
  validates :recipient_id, uniqueness: { scope: :event_id }
  validates :budget, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end