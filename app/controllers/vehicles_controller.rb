class VehiclesController < ApplicationController
  include UploadHelper

  before_filter :signed_in_user,    only: [:edit, :update, :destroy]
  before_filter :admin_user,        only: [:destroy]

  def create
  end

  def destroy
    @vehicle = Vehicle.find_by_vin(params[:id]) || Vehicle.find(params[:id])
    @vehicle.destroy
    flash[:success] = 'Vehicle destroyed'
    redirect_to vehicles_url
  end

  def edit
  end

  def notify
    @vehicle = Vehicle.find_by_vin(params[:id]) || Vehicle.find(params[:id])
    params[:notifications].each do |n|
      Notification.klass(n[:_type]).create(vehicle: @vehicle, details: n)
    end
    params[:totalRecords] # TODO check pagination
    return true
  end

  def index
    @vehicles = Vehicle.listed
    # build select menus
    @vehicles.map(&:make).uniq.compact.sort.each_with_object(@makes=[]){ |m,o| o << [Settings.vehicle_makes[m], m] }
    @vehicles.map(&:closest_color).uniq.reject(&:blank?).sort.each_with_object(@colors=[]){ |c,o| o << [c.capitalize, c] }
    @years = [*Date.today.year-10 .. Date.today.year].reverse # that splat is supposed to be there
    @miles = [ ['< 25,000', 25000],
               ['< 50,000', 50000],
               ['< 75,000', 75000],
               ['< 100,000', 100000] ]
    @types = ['Coupe', 'Sedan'].sort # not using this yet...
    @menu = 'buy'

    # filtering
    @vehicles = @vehicles.where(make: params[:make]) if params[:make].present?
    @vehicles = @vehicles.where(year: params[:year].to_i) if params[:year].present?
    min_p = params[:min_price]
    max_p = params[:max_price].presence || 1000000
    @vehicles = @vehicles.where(agreed_value: min_p.to_i .. max_p.to_i)
    @vehicles = @vehicles.where(closest_color: params[:closest_color]) if params[:closest_color].present?
    @vehicles = @vehicles.where('mileage < ?', params[:mileage].to_i) if params[:mileage].present?

    smart_listing_create(:vehicles, @vehicles, partial: 'vehicles/listing')

    respond_to do |f|
      f.js { render layout: false }
      f.html
    end
  end

  def model_query
    render json: Edmunds.query_models(params[:make])
  end

  def year_query
    render json: Edmunds.query_years(params[:make], params[:model])
  end

  def style_query
    render json: Edmunds.query_styles(params[:make], params[:model], params[:year])
  end

  def new
    @vehicle = Vehicle.new
  end

  def search
    if @veh = Vehicle.select{ |v| v.rvr == params[:rvr] }.first
      redirect_to @veh
    else
      flash[:error] = "Vehicle with RVR of #{params[:rvr].presence || 'nil'} not found."
      redirect_to root_path
    end
  end

  def sell
    params[:vehicle] ||= {}
    params[:user] ||= {}
    params[:ride] ||= {}
    @menu = 'sell'
    Settings.vehicle_makes.to_hash.each_with_object(@makes=[]){ |(k,v),o| o << [v,k] }
  end

  def show
    @vehicle = Vehicle.find_by_vin(params[:id]) || Vehicle.find_by_id(params[:id])
    unless @vehicle
      flash[:error] = "Vehicle with VIN of #{params[:id].presence || 'nil'} not found."
      redirect_to root_path and return
    end
    @vehicle.send(:build_options) and @vehicle.save if @vehicle.option_list.blank?
    @styles = Edmunds.query_styles(@vehicle.make, @vehicle.model, @vehicle.year).invert.to_a rescue []
    @vehicle_images = @vehicle.images
    @conditions = Vehicle.conditions.to_a
    @vehicle_condition = Vehicle.conditions[@vehicle.condition]
    @inspection_report = ['Body Exterior', 'Body Interior', 'Engine',
      'Transmission', 'Steering', 'Suspension', 'Brake System', 'Electrical System',
      'Convenience Group', 'Air Conditioning', 'Drive Axles', 'Wheels', 'Tires']
    @rides = admin? ? @vehicle.rides : (current_user.try(:rides) || [])
  end

  def update
    @vehicle = Vehicle.find_by_vin(params[:id]) || Vehicle.find(params[:id])

    @vehicle.color = params[:vehicle][:colors].presence
    @vehicle.options = params[:vehicle][:options].presence
    @vehicle.engine = params[:vehicle][:engine]
    @vehicle.transmission = params[:vehicle][:transmission]

    @vehicle.style = params[:vehicle][:style]
    @vehicle.condition = params[:vehicle][:condition].to_i if !params[:vehicle][:condition].blank?
    @vehicle.mileage = params[:vehicle][:mileage]

    render js: nil, status: :ok, layout: false if @vehicle.save
  end

end
