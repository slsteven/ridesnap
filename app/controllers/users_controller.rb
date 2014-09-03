class UsersController < ApplicationController
  before_filter :signed_in_user,
                only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,      only: [:edit, :update]
  before_filter :admin_user,        only: [:destroy]
  before_filter :already_signed_in, only: [:new, :create]

  def agent

  end

  def create
    @user = User.where(email: params[:user][:email]).first_or_initialize
    @user.name = params[:user][:name]
    @user.password = params[:user][:password]

    respond_to do |format|
      if @user.save
        format.html { redirect_to :back, success: "#{@user.name}'s account added to RideSnap" }
        format.js { render json: nil, status: :created, layout: false }
      else
        format.js { render json: @user.errors, status: :unprocessable_entity }
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