class GiftIdea < ApplicationRecord
  belongs_to :user
  belongs_to :event_recipient, optional:true

  validates :title, presence: true
  validates :status, inclusion: { in: %w[idea backlogged purchased delivered wrapped liked] }
  validates :user, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  after_initialize :set_default_status, if: :new_record?
  private
  def set_default_status
    self.status ||= 'idea'
  end

end
