# # frozen_string_literal: true

# class User < ApplicationRecord
#   has_secure_password
#   has_many :recipients, dependent: :destroy
  # has_many :events, dependent: :destroy

  # has_many :gift_ideas, dependent: :destroy
  # validates :username, presence: true, uniqueness: true
  # validates :email, presence: true, uniqueness: true
  # validates :first_name, :last_name, presence: true
  # validates :password, presence: true, on: :create
  

#   before_save :downcase_email
#   private
#   def downcase_email
#     self.email = email.downcase if email.present?
#   end

# end

class User < ApplicationRecord
  has_secure_password
  has_many :recipients, :foreign_key => :user_id, :dependent => :destroy
  #has_many :events, dependent: :destroy
  
  has_many :gift_ideas, dependent: :destroy
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
  validates :password_digest, presence: true, on: :create
  

  has_many :owned_events, class_name: "Event", foreign_key: :user_id, dependent: :destroy

  has_many :sent_event_invitations,
           class_name: "EventInvitation",
           foreign_key: :inviter_id,
           dependent: :destroy

  has_many :received_event_invitations,
           class_name: "EventInvitation",
           foreign_key: :invitee_id,
           dependent: :destroy

  has_many :invited_events,
           through: :received_event_invitations,
           source: :event

  has_many :attendees, dependent: :destroy
  has_many :attended_events, through: :attendees, source: :event
  has_many :event_messages, dependent: :destroy
  
  before_save :downcase_email!
  def visible_events
    Event
      .left_outer_joins(:attendees)
      .where("events.user_id = :id OR attendees.user_id = :id", id: id)
      .distinct
  end
  private
  def downcase_email!
    self.email = email.downcase if email.present?
  end

end
