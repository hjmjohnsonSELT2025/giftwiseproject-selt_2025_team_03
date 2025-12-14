class Event < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :user_id
  has_many :event_recipients, dependent: :destroy
  has_many :recipients, through: :event_recipients

  has_many :attendees, dependent: :destroy
  has_many :participants, through: :attendees, source: :user

  has_many :gift_ideas, through: :event_recipients

  has_many :event_invitations, dependent: :destroy
  has_many :invited_users, through: :event_invitations, source: :invitee
  has_many :event_messages, dependent: :destroy
  has_one :last_event_message, -> { order(created_at: :desc)}, class_name: "EventMessage"

  validates :name, presence: true
  validates :date, presence: true
  validates :budget, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true


  scope :upcoming, -> { where('date >= ?', Date.today).order(:date) }
  scope :past, -> { where('date < ?', Date.today).order(date: :desc) }

  def days_until
    (date - Date.today).to_i
  end

  def total_spent
    gift_ideas.where(status: ['purchased', 'delivered', 'wrapped']).sum(:price)
  end

  def budget_remaining
    budget.to_f - total_spent
  end

  def budget_percentage
    return 0 if budget.nil? || budget.zero?
    ((total_spent / budget.to_f) * 100).round
  end

  def viewable_by?(user)
        user_id == user.id || attendees.exists?(user_id: user.id)
  end

  def editable_by?(user)
        user_id == user.id || attendees.exists?(user_id: user.id, role: Attendee.roles[:editor])
  end

  def recipients_for(viewer)
        viewer.id == user_id ? recipients : recipients.publicly_visible
  end

  def week_from_now?
    date.to_date == 1.week.from_now.to_date
  end

  def day_from_now?
    date.to_date == 1.day.from_now.to_date
  end
end