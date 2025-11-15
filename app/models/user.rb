# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  before_save :downcase_email, :create_session_token
  private
  def downcase_email
    self.email = email.downcase if email.present?
  end
  def create_session_token
    self.session_token = SecureRandom.urlsafe_base64
  end
end
