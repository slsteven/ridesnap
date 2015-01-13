class RidesController < ApplicationController
  before_filter :correct_user,        only: [:update, :destroy]
  before_filter :user_ride,           only: [:show]
  respond_to :html, :js

  def create
    params[:vehicle] ||= {}
    params[:user] ||= {}
    params[:ride] ||= {}
    params[:user][:zip_code] = params[:ride][:zip_code]
    Settings.vehicle_makes.to_hash.each_with_object(@makes=[]){ |(k,v),o| o << [v,k] }
    params[:vehicle][:vin] = params[:vehicle_vin].presence
    @intent = params[:vehicle][:vin] ? 'buy' : 'sell'
    @menu = @intent

    @vehicle = Vehicle.where(vin: params[:vehicle][:vin]).first_or_initialize(vehicle_params)
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
    @user = User.where(email: params[:user][:email]).first_or_initialize(user_params)

    if params[:admin] && @vehicle.save
      redirect_to @vehicle and return
    end

    if @user.save && @vehicle.save
      params[:ride][:relation] = @intent == 'buy' ? 'tester' : 'seller'
      params[:ride][:scheduled_at] = Chronic.parse(params[:ride][:scheduled_at]) || Time.now
      params[:ride][:vehicle_id] = @vehicle.id
      params[:ride][:user_id] = @user.id
      @ride = Ride.new(ride_params)

      if @ride.save
        flash[:success] = "Appointment confirmed for #{@ride.scheduled_at.strftime('%A, %B')} #{@ride.scheduled_at.day.ordinalize}! We've sent you a confirmation email."
        redirect_to @ride
        @ride.confirm_ride
      else
        flash.now[:error] = "Something went wrong saving your ride... please try again"
        render 'rides/new'
      end
    else
      flash.now[:error] = "Something went wrong saving user/vehicle... please try again"
      render 'rides/new'
    end
  end

  def new
    params[:vehicle] ||= {}
    params[:user] ||= {}
    params[:ride] ||= {}
    @vehicle = Vehicle.find_by_vin(params[:vehicle_vin])
    @intent = @vehicle.present? ? 'buy' : 'sell'
    @menu = @intent
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
    redirect_to(@ride) unless @ride.with?(current_user) || admin?
  end

  def user_ride
    @ride = Ride.find(params[:id])
    redirect_to root_path unless @ride.with?(current_user) || admin?
  end

  def ride_params
    params.require(:ride).permit!
  end

end
