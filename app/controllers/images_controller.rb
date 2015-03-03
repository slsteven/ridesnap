class ImagesController < ApplicationController
  respond_to :js

  def create
    @vehicle = Vehicle.find_by_vin(params[:vehicle_id]) || Vehicle.find(params[:vehicle_id])
    @image = @vehicle.images.build(image_params)
    if @image.save
      respond_with @image
    else
      flash.now[:error] = 'Invalid image'
    end
  end

  def destroy
    @image = Image.find(params[:id])
    @vehicle = @image.vehicle
    @image.destroy
    redirect_to @vehicle
  end

  def index
  end

private

  def image_params
    params.require(:image).permit!
  end

end
