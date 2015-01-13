class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  include UsersHelper

  def user_params
    params.require(:user).permit(:name, :email, :phone, :password, :zip_code)
  end

  def vehicle_params
    params.require(:vehicle).permit!
  end

end
