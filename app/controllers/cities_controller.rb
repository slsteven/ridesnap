class CitiesController < ApplicationController
  before_filter :admin_user,        only: [:index, :update]

  def create
    loc = Location.from_zip params[:zip_code]
    if loc.any?
      @city = City.where(city: loc[:city], state: loc[:state]).first_or_initialize
      @city.country = loc[:country]
      @city.requests += 1
      if @city.save and @city.available?
        flash[:success] = "We're actually already available in #{@city.city}! Get started, and we'll help you sell your ride."
      else
        flash[:notice] = "Thanks! We'll let you know when we're headed to #{@city.city}!"
      end
    else
      flash[:alert] = "Not even Google could find a location for '#{params[:zip_code]}'"
    end
    redirect_to :back
  end

  def index
    @cities = City.order(requests: :desc)
  end

  def update
    @city = City.find params[:id]
    @city.update_attributes(params[:city].permit(:available))
    render json: @city
  end

  private

    def admin_user
      redirect_to(root_path) unless current_user.try(:admin?)
    end
end