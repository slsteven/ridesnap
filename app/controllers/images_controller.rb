class ImagesController < ApplicationController
  respond_to :js

  def create
    @vehicle = Vehicle.find(params[:vehicle_id])
    @image = @vehicle.images.build(image_params)
    if @image.save
      respond_with @image
    else
      flash.now[:error] = 'Invalid image'
    end
  end

  def index
  end

private

  def image_params
    params.require(:image).permit!
  end

end
