class RidesController < ApplicationController
  before_filter :correct_user,        only: [:update, :destroy]

  def create
    @vehicle = Vehicle.find(params[:vehicle_id].to_i)

    @user = User.where(email: params[:email]).first_or_initialize
    @user.name = params[:name]
    @user.phone = params[:phone].delete('^0-9')

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

private

  def correct_user
    @ride = Ride.find(params[:id])
    redirect_to(@ride) unless @ride.with?(current_user) || current_user.admin?
  end

end
