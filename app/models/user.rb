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
  

  has_many :events, dependent: :destroy

  has_many :sent_event_invitations,
           class_name: "EventInvitation",
           foreign_key: :inviter_id,
           dependent: :destroy

  has_many :received_event_invitations,
           class_name: "EventInvitation",
           foreign_key: :inviter_id,
           dependent: :destroy

  has_many :invited_events,
           through: :received_event_invitations,
           source: :event

  before_save :downcase_email!
  private
  def downcase_email!
    self.email = email.downcase if email.present?
  end
end
