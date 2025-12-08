class UserMailer < ApplicationMailer
  default from: "notifications@example.com"

  def welcome_email(user)
    @user = user
    @url  = "http://example.com/login"
    mail(to: @user.email, subject: "Welcome to My Awesome Site")
  end

  def login_notification(user)
    @user = user

    mail(
      to: @user.email,
      subject: "You just logged in!"
    )
  end
end
