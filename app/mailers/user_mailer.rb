class UserMailer < ApplicationMailer
  def welcome_email(user, temporary_password)
    @user = user
    @temporary_password = temporary_password
    @login_url = "http://localhost:5173/login"
    mail(to: @user.email, subject: "Welcome to our platform")
  end

  def verification_email(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: "Verify your email")
  end

  def password_reset_email(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: "Password Reset Instructions")
  end
end
