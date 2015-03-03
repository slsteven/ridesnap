class UserMailer < ActionMailer::Base
  default from: Settings.app.email.info

  def password_reset(user_id)
    @user = User.find(user_id)
    mail to: @user.email, subject: "#{Settings.app.name} Password Reset"
  end

  def agent_application(user_id)
    @user = User.find(user_id)
    mail to: Settings.app.email.steven, subject: "#{Settings.app.name} Agent Application"
  end
end
