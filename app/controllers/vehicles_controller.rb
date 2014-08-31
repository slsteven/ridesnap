class VehiclesController < ApplicationController
  def create
    @vehicle = Vehicle.new(vehicle_params)
    if @vehicle.save
      sign_in @vehicle
      flash[:success] = "Vehicle created"
      redirect_to @vehicle
    else
      render 'new'
    end
  end

  def destroy
    Vehicle.find(params[:id]).destroy
    flash[:success] = "Vehicle destroyed"
    redirect_to vehicles_url
  end

  def edit
  end

  def index
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
    render json: Edmunds.typical_value(params[:style], zip: params[:zip].presence)
  end

  def new
    @vehicle = Vehicle.new
  end

  def schedule_inspection
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def show
    @vehicle = Vehicle.find(params[:id])
  end

  def update
    if @vehicle.update_attributes(vehicle_params)
      flash[:success] = "Vehicle updated"
      sign_in @vehicle
      redirect_to @vehicle
    else
      render 'edit'
    end
  end

  private

    def vehicle_params
      params.require(:vehicle).permit!
    end
end
