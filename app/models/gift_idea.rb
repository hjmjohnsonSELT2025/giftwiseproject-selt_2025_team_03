class GiftIdea < ApplicationRecord
  belongs_to :event_recipient

  validates :title, presence: true
  validates :status, inclusion: { in: %w[idea backlogged purchased delivered wrapped liked] }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
