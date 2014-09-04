class UserMailer < ActionMailer::Base
  default from: Settings.app.email.info

  def password_reset(user)
    @user = user
    mail to: @user.email, subject: "#{Settings.app.name} Password Reset"
  end
end
