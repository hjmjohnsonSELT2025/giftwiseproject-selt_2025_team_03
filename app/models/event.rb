class Event < ApplicationRecord
  belongs_to :user
  has_many :event_recipients, dependent: :destroy
  has_many :recipients, through: :event_recipients
  has_many :gift_ideas, through: :event_recipients

  validates :name, presence: true
  validates :date, presence: true
  validates :budget, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  end
