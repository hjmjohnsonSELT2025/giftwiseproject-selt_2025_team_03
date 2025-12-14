
class Recipient < ApplicationRecord 
    validate :source_user_must_be_public, if: -> { source_user_id.present? }
    belongs_to :creator, class_name: "User", foreign_key: :user_id
    belongs_to :source_user, class_name: "User", optional: true
    
    has_many :event_recipients, dependent: :destroy
    has_many :events, through: :event_recipients
    has_many :gift_ideas, through: :event_recipients

    validates :name, presence: true,
              uniqueness: {
                scope: :user_id,
                case_sensitive: false,
                message: "is already in your recipient list."
              }
    
    # Scoping
    scope :publicly_visible, -> { where(visible: true) }
    scope :private_only, -> { where(visible: false) }

    def display_likes
      source_user ? source_user.likes : likes
    end
    def display_dislikes
      source_user ? source_user.dislikes : dislikes
    end
    def display_name
      source_user ? [source_user.first_name, source_user.last_name].compact.join(" ") : name
    end
    def source_user_must_be_public
            unless source_user&.public_profile?
                            errors.add(:source_user, "must have a public profile.")
            end
    end
end