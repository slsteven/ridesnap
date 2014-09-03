class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase.strip)
    errors = {email: ['invalid email/password combination'], password: ['']}
    respond_to do |format|
      if @user.try :authenticate, params[:session][:password]
        sign_in @user
        format.html { redirect_to :back, success: "Welcome back, #{@user.first_name}" }
        format.js { render json: nil, status: :accepted, layout: false }
      else
        format.js { render json: errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

  def show
  end
end