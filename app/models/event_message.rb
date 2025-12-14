class EventMessage < ApplicationRecord
  belongs_to :event
  belongs_to :user
  validates :body, presence: true, length: {maximum: 2000}
end
