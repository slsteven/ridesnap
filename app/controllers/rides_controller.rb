class RidesController < ApplicationController
  before_filter :correct_user,        only: [:update, :destroy]
  respond_to :html, :js

  def create
    @vehicle = Vehicle.where(id: params[:vehicle][:id]).first_or_initialize(vehicle_params)
    @vehicle.style ||= params[:vehicle][:style].presence
    value = Edmunds.typical_value @vehicle.style, zip: params[:ride][:zip_code].presence
    sources = [value[:trade_in], value[:private_party]]
    avg = sources.sum / sources.size.to_f
    dif = value[:private_party] - avg
    adj = dif * 0 # this will let us adjust the price easily while staying in the bounds 0.0 .. 1.0
    @vehicle.preliminary_value ||= {
      snap_up: (avg + adj).round(-2),
      trade_in: value[:trade_in].round(-2),
      ride_snap: value[:private_party].round(-2)
    }
    @user = User.where(id: params[:user_id]).first_or_initialize(user_params)

    if @user.save && @vehicle.save
      relation = params[:intent] == 'buy' ? 'tester' : 'seller'
      params[:ride][:scheduled_at] = Chronic.parse(params[:ride][:scheduled_at]) || Time.now
      @ride = @user.rides.send(relation).where(vehicle_id: @vehicle.id).first_or_initialize(ride_params)

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
    @vehicle = Vehicle.find_by_vin(params[:vin])
    @menu = params[:intent]
    Settings.vehicle_makes.to_hash.each_with_object(@makes=[]){ |(k,v),o| o << [v,k] }
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

  def ride_params
    params.require(:ride).permit!
  end

end
