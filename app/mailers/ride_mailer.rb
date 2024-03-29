class RideMailer < ActionMailer::Base
  default from: Settings.app.email.info

  def confirm_with_user(ride_id)
    @ride = Ride.find(ride_id)
    @user = @ride.user
    @vehicle = @ride.vehicle
    mail to: @user.email, subject: "#{Settings.app.name} Vehicle Inspection"
  end

  def confirm_with_agent(ride_id)
    @ride = Ride.find(ride_id)
    @user = @ride.user
    @vehicle = @ride.vehicle
    mail to: Settings.app.email.steven, subject: "#{@user.name}'s Vehicle Inspection"
  end
end
