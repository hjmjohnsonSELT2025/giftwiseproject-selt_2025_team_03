class Event < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :user_id
  has_many :event_recipients, dependent: :destroy
  has_many :recipients, through: :event_recipients
  has_many :gift_ideas, through: :event_recipients

  validates :name, presence: true
  validates :date, presence: true
  validates :budget, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true


  scope :upcoming, -> { where('date >= ?', Date.today).order(:date) }
  scope :past, -> { where('date < ?', Date.today).order(date: :desc) }

  def days_until
    (date - Date.today).to_i
  end

  def total_spent
    gift_ideas.where(status: ['purchased', 'delivered']).sum(:price)
  end

  def budget_remaining
    budget.to_f - total_spent
  end

  def budget_percentage
    return 0 if budget.nil? || budget.zero?
    ((total_spent / budget) * 100).round
  end
end
