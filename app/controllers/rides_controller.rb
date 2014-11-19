class RidesController < ApplicationController
  before_filter :correct_user,        only: [:update, :destroy]
  respond_to :html, :js

  def create
    @vehicle = Vehicle.find(params[:vehicle_id].to_i)
    if params[:user_id]
      @user = User.find_by_id(params[:user_id])
    else
      @user = User.where(email: params[:email]).first_or_initialize
      @user.name = params[:name]
      @user.phone = params[:phone].delete('^0-9')
    end

    if @user.save
      @ride = @user.rides
                   .where(vehicle_id: @vehicle.id, relation: 'seller')
                   .first_or_initialize
      @ride.scheduled_at = Chronic.parse(params[:scheduled_at]) || Time.now
      @ride.address = params[:address]
      @ride.zip_code = params[:zip_code]

      if @ride.save
        flash[:success] = "Appointment confirmed for #{@ride.scheduled_at.strftime('%A, %B')} #{@ride.scheduled_at.day.ordinalize}! We've sent you a confirmation email"
        redirect_to @ride
        @ride.confirm_ride
      else
        flash.now[:error] = "Something went wrong... please try again"
        render 'rides/new'
      end
    else
      flash.now[:error] = "Something went wrong... please try again"
      render 'rides/new'
    end
  end

  def new
    @vehicle = Vehicle.find(params[:vehicle_id])
  end

  def show
    @ride = Ride.find(params[:id])
    @user = @ride.user
    @vehicle = @ride.vehicle
    @menu = 'start'
  end

  def update
    @ride = Ride.find(params[:id])
    @ride.scheduled_at = Chronic.parse(params[:ride][:scheduled_at]) || Time.now
    @ride.address = params[:ride][:address]
    @ride.zip_code = params[:ride][:zip_code]
    @ride.save
    @ride.confirm_ride if @ride.errors.blank?
    respond_with @ride, layout: false
  end

private

  def correct_user
    @ride = Ride.find(params[:id])
    redirect_to(@ride) unless @ride.with?(current_user) || current_user.admin?
  end

end
