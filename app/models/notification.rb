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
#
# Indexes
#
#  index_notifications_on_ended_at    (ended_at)
#  index_notifications_on_type        (type)
#  index_notifications_on_vehicle_id  (vehicle_id)
#

class Notification < ActiveRecord::Base

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

  def self.klass(n)
    case n.upcase
    when 'GEOFENCE'
      Geofence
    when 'IGNITIONSTATUS'
      Ignition
    when 'LOWBATTERY'
      Battery
    when 'NUMERICDATAKEY'
      NumericData
    when 'TIMEOFDAY'
      TimeOfDay
    when 'TROUBLECODE'
      TroubleCode
    when 'VEHICLEHARSHACCEL','VEHICLEHARSHDECEL','VEHICLEHARSHRIGHT','VEHICLEHARSHLEFT','VEHICLEIMPACT'
      DriverBehavior
    when 'VEHICLECONNECTED','VEHICLEDISCONNECTED','VEHICLETOWED'
      Connection
    else
      Notification
    end
  end

end
