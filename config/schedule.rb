# frozen_string_literal: true

every 1.day, at: '12:20 pm' do
  runner "EventReminderJob.perform_now"
end