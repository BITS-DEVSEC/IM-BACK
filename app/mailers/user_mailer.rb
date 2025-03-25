class UserMailer < ApplicationMailer
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
