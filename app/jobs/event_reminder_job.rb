class EventReminderJob < ApplicationJob
  queue_as :default

  def perform
    Event.includes(:creator).find_each do |event|
      next unless event.date.present?

      user = event.creator
      next unless user.email_notifications?

      days_left = (event.date.to_date - Date.current).to_i

      case days_left
      when 7
        EventMailer.upcoming_event_week(event).deliver_now
      when 1
        EventMailer.upcoming_event_day(event).deliver_now
      end
    end
  end
end
