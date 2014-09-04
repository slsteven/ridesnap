class PasswordResetsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    user.send_password_reset if user
    redirect_to :back, notice: 'Email sent with password reset instructions'
  end

  def edit
    @user = User.find_by!(password_reset_token: params[:id])
    render 'pages/home'
  end

  def update
    @user = User.find_by!(password_reset_token: params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      flash[:alert] = 'Password reset has expired'
      redirect_to :back
    elsif @user.update_attributes(params[:user].permit(:password))
      sign_in @user
      flash[:success] = 'Password has been reset'
      redirect_to root_url
    else
      render :edit
    end
  end
end
