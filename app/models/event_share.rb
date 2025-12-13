class EventShare < ApplicationRecord
  belongs_to :event
  belongs_to :user
  enum role: { viewer: 0, editor: 1}
end