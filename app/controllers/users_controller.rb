class UsersController < ApplicationController
  before_filter :signed_in_user,
                only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,      only: [:edit, :update]
  before_filter :admin_user,        only: [:destroy]
  before_filter :already_signed_in, only: [:new, :create]

  def agent

  end

  def create
    @user = User.build params[:user]

    respond_to do |format|
      case @user[:status]
      when 'fresh user'
        flash[:success] = "#{@user[:object].name} added to RideSnap"
        format.html { redirect_to :back }
        format.js { render js: "location.reload();" }
      when 'returning user'
        flash[:success] = "Welcome back #{@user[:object].first_name}! Your account has been updated"
        format.html { redirect_to :back }
        format.js { render js: "location.reload();" }
      when 'current user'
        if @user[:object].authenticate params[:user][:password]
          sign_in @user[:object]
          flash[:success] = "Welcome back #{@user[:object].first_name}! You already have an account, so you've been signed in"
          format.html { redirect_to :back }
          format.js { render js: "location.reload();" }
        else
          errors = {email: ['account exists... invalid email/password combination'], password: ['']}
          format.js { render json: errors, status: :expectation_failed } # 417
        end
      else
        format.js { render json: @user[:object].errors, status: :unprocessable_entity } # 422
      end
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash.now[:success] = "User destroyed"
    redirect_to users_url
  end

  def edit
  end

  def index
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    if @user.update_attributes(user_params)
      flash.now[:success] = "User updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def user_params
      params.require(:user).permit(:name, :email, :password)
    end

end