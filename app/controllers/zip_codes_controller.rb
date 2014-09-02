class ZipCodesController < ApplicationController
  def create
    loc = Location.from_zip params[:zip_code]
    ZipCode.create(loc)
    flash[:success] = "Thanks! We'll let you know when we're headed to #{loc[:city]}!"
    redirect_to :back
  end
end