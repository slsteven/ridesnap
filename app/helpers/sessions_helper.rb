module SessionsHelper

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

  # in and out
  def sign_in(user)
    remember_token = User.generate_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.digest(remember_token))
    self.current_user = user
  end
  def sign_out
    current_user.update_attribute(:remember_token,
                                  User.digest(User.generate_token))
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  # easily verify whether a user is currently logged in
  def signed_in?
    !current_user.nil?
  end

  # getter and setter methods
  def current_user=(user)
    @current_user = user
  end
  def current_user
    remember_token = User.digest(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  # compare a user against the current user
  def current_user?(user)
    user == current_user
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  # check if a user is signed in before given certain access
  def signed_in_user
    unless signed_in?
      store_location
      redirect_to root_path, notice: "Please sign in."
    end
  end

  def store_location
    session[:return_to] = request.url
  end
end