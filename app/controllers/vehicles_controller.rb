class VehiclesController < ApplicationController
  before_filter :signed_in_user,    only: [:index, :edit, :update, :destroy]
  before_filter :admin_user,        only: [:index, :destroy]

  def create
    params[:vehicle][:zip_code] = params[:vehicle][:zip_code].presence
    value = Edmunds.typical_value params[:vehicle][:style], zip: params[:vehicle][:zip_code]
    params[:vehicle][:preliminary_value] = value
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
  end

  def update

  end

  private

    def vehicle_params
      params.require(:vehicle).permit!
    end
end
