class Recipient < ApplicationRecord
  belongs_to :user
  has_many :event_recipients, dependent: :destroy
  has_many :events, through: :event_recipients
  has_many :gift_ideas, through: :event_recipients

  validates :name, presence: true

  attr_accessor :birthday if Rails.env.test?
end