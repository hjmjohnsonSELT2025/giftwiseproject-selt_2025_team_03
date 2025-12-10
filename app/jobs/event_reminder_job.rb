class EventReminderJob < ApplicationJob
  queue_as :default

  def perform
    # Do something later
    Event.includes(:user).find_each do |event|
      next unless event.date.present?

      user = event.user
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
