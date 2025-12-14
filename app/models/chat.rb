class Chat < ApplicationRecord
  acts_as_chat
  belongs_to :user, optional: true
  belongs_to :event_recipient, optional: true
end
