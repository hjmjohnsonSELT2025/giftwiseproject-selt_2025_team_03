# frozen_string_literal: true

every 1.day, at: '12:00 am' do
  runner "EventReminderJob.perform_now"
end