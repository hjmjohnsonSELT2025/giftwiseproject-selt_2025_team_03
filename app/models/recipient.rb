# Initial definition 
# ------------------------------
# class Recipient < ApplicationRecord
#   belongs_to :user
#   has_many :event_recipients, dependent: :destroy
#   has_many :events, through: :event_recipients
#   has_many :gift_ideas, through: :event_recipients

#   validates :name, presence: true

# end
# Shared/Collaborative definition
# ------------------------------

class Recipient < ApplicationRecord 
    belongs_to :creator, class_name: "User", foreign_key: :user_id
    
    has_many :event_recipients, dependent: :destroy
    has_many :events, through: :event_recipients
    has_many :gift_ideas, through: :event_recipients

    validates :name, presence: true

    # Scoping
    scope :publicly_visible, -> { where(visible: true) }
    scope :private_only, -> { where(visible: false) }
end