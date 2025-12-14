class Attendee < ApplicationRecord
  belongs_to :event
  belongs_to :user

  enum role: { viewer: 0, editor: 1 }
  validates :event_id, uniqueness: { scope: :user_id }
end
