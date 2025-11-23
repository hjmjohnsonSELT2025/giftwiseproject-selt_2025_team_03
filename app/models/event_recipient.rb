class EventRecipient < ApplicationRecord
  belongs_to :event
  belongs_to :recipient
end
