# == Schema Information
#
# Table name: notifications
#
#  id         :integer          not null, primary key
#  vehicle_id :integer
#  type       :string
#  details    :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ended_at   :datetime
#  trip_id    :integer
#
# Indexes
#
#  index_notifications_on_details     (details)
#  index_notifications_on_ended_at    (ended_at)
#  index_notifications_on_trip_id     (trip_id)
#  index_notifications_on_type        (type)
#  index_notifications_on_vehicle_id  (vehicle_id)
#

class Notification < ActiveRecord::Base

  belongs_to :vehicle

  def self.data_keys
    [
      'GEN_DTC',                          # Diagnostic Trouble Codes
      'GEN_VOLTAGE',                      # Battery Voltage
      'GEN_TRIP_MILEAGE',                 # Trip Mileage (calculate from ignition on to ignition off via GPS)
      'GEN_ODOMETER',                     # Vehicle Reported Odometer
      'GEN_WAYPOINT',                     # GPS Location
      'GEN_HEADING',                      # Heading (degrees clockwise from due north)
      'GEN_RPM',                          # Engine Speed
      'GEN_FUELLEVEL',                    # Percentage of Fuel Remaining
      'GEN_FUELRATE ',                    # Rate of Fuel Consumption
      'GEN_ENGINE_COOLANT_TEMP',          # Engine Temperature
      'GEN_SPEED',                        # Maximum Speed Recorded (since the previous reading)
      'GEN_NEAREST_ADDRESS',              # The physical address nearest to the associated Waypoint

      'VEHICLE_EVENT_CONNECTED',          # Vehicle device was connected
      'VEHICLE_EVENT_DISCONNECTED',       # Vehicle device was disconnected
      'VEHICLE_EVENT_TOWED',              # Towing has been detected
      'VEHICLE_EVENT_TOWED_BREADCRUMB',   # A breadcrumb indicating the vehicle is being towed
      'VEHICLE_EVENT_HARSH_ACCEL',        # Harsh acceleration
      'VEHICLE_EVENT_HARSH_DECEL',        # Harsh deceleration
      'VEHICLE_EVENT_HARSH_RIGHT',        # Harsh right turn
      'VEHICLE_EVENT_HARSH_LEFT',         # Harsh left turn
      'VEHICLE_EVENT_HARSH_IMPACT'        # Impact has been detected
    ].freeze
  end

  def self.klass(n=nil)
    case n.try(:upcase)
    when 'GEOFENCE','GEN_WAYPOINT'
      Location
    when 'IGNITIONSTATUS'
      Ignition
    when 'LOWBATTERY','GEN_VOLTAGE','GEN_ODOMETER','GEN_RPM','GEN_FUELLEVEL','GEN_FUELRATE','GEN_ENGINE_COOLANT_TEMP','GEN_SPEED'
      Level
    when 'NUMERICDATAKEY'
      NumericData
    when 'TIMEOFDAY'
      TimeOfDay
    when 'TROUBLECODE','GEN_DTC'
      TroubleCode
    when 'VEHICLEHARSHACCEL','VEHICLEHARSHDECEL','VEHICLEHARSHRIGHT','VEHICLEHARSHLEFT','VEHICLEIMPACT','VEHICLE_EVENT_HARSH_ACCEL','VEHICLE_EVENT_HARSH_DECEL','VEHICLE_EVENT_HARSH_RIGHT','VEHICLE_EVENT_HARSH_LEFT','VEHICLE_EVENT_HARSH_IMPACT'
      DriverBehavior
    when 'VEHICLECONNECTED','VEHICLEDISCONNECTED','VEHICLE_EVENT_CONNECTED','VEHICLE_EVENT_DISCONNECTED'
      Connection
    when 'VEHICLETOWED','VEHICLE_EVENT_TOWED','VEHICLE_EVENT_TOWED_BREADCRUMB'
      Tow
    when 'TRIP'
      Trip
    else
      Notification
    end
  end

end
