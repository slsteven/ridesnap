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
    value = Edmunds.typical_value params[:style], zip: params[:zip].presence
    params[:preliminary_value] = value
    @vehicle = Vehicle.create params.except(:action, :controller).permit!
    value[:vehicle_id] = @vehicle.id
    render json: value
  end

  def new
    @vehicle = Vehicle.new
  end

  def schedule_confirm
    @user = User.where(email: params[:email]).first_or_initialize
    @user.name = params[:name]
    @user.phone = params[:phone]

    # @ride = Ride.new
    #   datetime
    #   address
    #   zip_code
    #   vehicle_id

    if @user.save
      @ride = @user.rides
                   .where(vehicle_id: params[:vehicle_id], relation: 'seller')
                   .first_or_initialize
      @ride.datetime = params[:datetime]
      @ride.address = params[:address]
      @ride.zip_code = params[:zip_code]
      @ride.owner = true

      if @ride.save
        flash[:success] = "Appointment confirmed!"
      else
        flash[:error] = "Something went wrong... please try again"
        render 'pages/start'
      end
    else
      flash[:error] = "Something went wrong... please try again"
      render 'pages/start'
    end
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
