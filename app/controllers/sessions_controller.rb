class SessionsController < ApplicationController

  def callback
    @auth = params[:provider].capitalize.constantize.first_or_initialize
    code = params[:code] || params[:query_string]
    @auth.get_token(auth_code: code)
    if @auth.save
      flash[:success] = "Authentication successful"
    else
      flash[:error] = "Authentication failed"
    end
    redirect_to root_url
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase.strip)
    errors = {email: ['invalid email/password combination'], password: ['']}
    respond_to do |format|
      if @user.try :authenticate, params[:session][:password]
        sign_in @user
        flash[:success] = "Welcome back, #{@user.first_name}"
        format.html { redirect_to :back }
        format.js { render js: "location.reload();" }
      else
        format.js { render json: errors, status: :unprocessable_entity } # 422
      end
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

  def new
  end

end