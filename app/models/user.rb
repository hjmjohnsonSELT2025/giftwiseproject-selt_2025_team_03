# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :recipients, dependent: :destroy
  has_many :events, dependent: :destroy

  has_many :gift_ideas, dependent: :destroy
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
  validates :password, presence: true, on: :create
  
  before_save :downcase_email!
  private
  def downcase_email!
    self.email = email.downcase if email.present?
  end

end
