# frozen_string_literal: true

every 1.day, at: '11:58 pm' do
  runner "EventReminderJob.perform_now"
end