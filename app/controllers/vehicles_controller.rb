class VehiclesController < ApplicationController
  before_filter :signed_in_user,    only: [:index, :edit, :update, :destroy]
  before_filter :admin_user,        only: [:index, :destroy]

  def create
    params[:vehicle][:zip_code] = params[:vehicle][:zip_code].presence
    params[:vehicle][:preliminary_value] = {
      trade_in: params[:trade_in_value],
      ridesnap: params[:ridesnap_value],
      snapup: params[:snapup_value]
    }
    params[:vehicle].slice!(:make, :model, :year, :style, :zip_code, :description, :preliminary_value)
    @vehicle = Vehicle.new params[:vehicle].permit!
    @menu = 'start'

    render new_ride_path if @vehicle.save
  end

  def destroy
    Vehicle.find(params[:id]).destroy
    flash.now[:success] = "Vehicle destroyed"
    redirect_to vehicles_url
  end

  def edit
  end

  def index
    @vehicles = Vehicle.all
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

  def query
    value = Edmunds.typical_value params[:style], zip: params[:zip].presence
    sources = [value[:trade_in], value[:private_party]]
    avg = sources.sum / sources.size.to_f
    dif = value[:private_party] - avg
    value[:buy_now] = (avg + (dif * 0)).round(-2) # this will let us adjust the price easily while staying in the bounds
    value[:trade_in] = value[:trade_in].round(-2)
    value[:ride_snap] = value[:private_party].round(-2)
    render json: value
  end

  def new
    @vehicle = Vehicle.new
  end

  def show
    @vehicle = Vehicle.find(params[:id])
    @vehicle.send(:build_options) and @vehicle.save if @vehicle.options.nil?
    @styles = Edmunds.query_styles(@vehicle.make, @vehicle.model, @vehicle.year).invert.to_a rescue []
    @vehicle_images = ['about.jpg', 'home.jpg']
    @conditions = Vehicle.conditions.to_a
    @vehicle_condition = Vehicle.conditions[@vehicle.condition]
    @inspection_report = ['Body Exterior', 'Body Interior', 'Engine',
      'Transmission', 'Steering', 'Suspension', 'Brake System', 'Electrical System',
      'Convenience Group', 'Air Conditioning', 'Drive Axles', 'Wheels', 'Tires']
  end

  def update
    @vehicle = Vehicle.find(params[:id])
    @vehicle.options = {e: params[:vehicle][:engine], t: params[:vehicle][:transmission], o: (params[:vehicle][:options].presence || []), c: (params[:vehicle][:colors].presence || {})}
    @vehicle.style = params[:vehicle][:style]
    @vehicle.condition = params[:vehicle][:condition].to_i if !params[:vehicle][:condition].blank?
    @vehicle.mileage = params[:vehicle][:mileage]
    @vehicle.save
  end

  private

    def vehicle_params
      params.require(:vehicle).permit!
    end
end
