class CitiesController < ApplicationController
  def create
    loc = Location.from_zip params[:zip_code]
    @city = City.where(city: loc[:city], state: loc[:state]).first_or_initialize
    @city.country = loc[:country]
    @city.requests += 1
    if @city.save and @city.available?
      flash[:success] = "We're actually already available in #{@city.city}! Get started, and we'll help you sell your ride."
    else
      flash[:notice] = "Thanks! We'll let you know when we're headed to #{@city.city}!"
    end
    redirect_to :back
  end
end