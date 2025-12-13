class EventInvitation < ApplicationRecord
  belongs_to :event
  belongs_to :inviter, class_name: "User"
  belongs_to :invitee, class_name: "User"
  
  validates :event_id, uniqueness: { scope: :invitee_id }
end