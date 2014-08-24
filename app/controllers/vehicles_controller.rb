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

  def new
    @vehicle = Vehicle.new
  end

  def query
    respond_to do |format|
      format.js { render layout: false }
    end
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
