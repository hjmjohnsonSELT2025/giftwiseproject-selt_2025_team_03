class GiftIdea < ApplicationRecord
  belongs_to :user
  belongs_to :event_recipient, optional:true

  validates :title, presence: true
  validates :status, inclusion: { in: %w[idea backlogged purchased delivered wrapped liked] }
  validates :user, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validate :validate_budget, if: :purchased?

  after_initialize :set_default_status, if: :new_record?

  def purchased?
    status == 'purchased' || status == 'delivered' || status == 'wrapped'
  end

  private

  def set_default_status
    self.status ||= 'idea'
  end

  def validate_budget
    return unless price.present? && event_recipient.present?

    event = event_recipient.event

    if event.budget.present? && event.budget > 0
      current_spent = GiftIdea.joins(:event_recipient)
                              .where(event_recipients: { event_id: event.id })
                              .where(status: ['purchased', 'delivered', 'wrapped'])
                              .where.not(id: id)
                              .sum(:price)

      if (current_spent + price) > event.budget
        errors.add(:base, :exceeds_budget, message: "exceeds the remaining budget for the event.")
        return
      end
    end

    if event_recipient.budget.present? && event_recipient.budget > 0
      recipient_spent = GiftIdea.where(event_recipient: event_recipient)
                                .where(status: ['purchased', 'delivered', 'wrapped'])
                                .where.not(id: id)
                                .sum(:price)

      if (recipient_spent + price) > event_recipient.budget
        errors.add(:base, :exceeds_budget, message: "exceeds the remaining budget for the recipient.")
      end
    end
  end
end