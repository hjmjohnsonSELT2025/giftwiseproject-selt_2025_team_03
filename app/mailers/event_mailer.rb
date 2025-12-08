class EventMailer < ApplicationMailer
  default from: "notifications@example.com"

  def upcoming_event_week(event)
    @event = event
    @user = event.user

    mail(
      to: @user.email,
      subject: "Reminder: #{@event.name} is 1 week away!!"
    )
  end

  def upcoming_event_day(event)
    @event = event
    @user = event.user

    mail(
      to: @user.email,
      subject: "HOLY SMOKES! #{@event.name} is tommorrow!!"
    )
  end


  def weekly_summary(user, events, recipients)
    @event = events
    @user = user
    @recipient = recipients

    mail(
      to: @user.email,
      subject: "Your Weekly GiftWise Summary"
    )
  end
end
