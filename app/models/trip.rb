# == Schema Information
#
# Table name: trips
#
#  id         :integer          not null, primary key
#  vehicle_id :integer
#  details    :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_trips_on_details     (details)
#  index_trips_on_vehicle_id  (vehicle_id)
#

class Trip < ActiveRecord::Base

  EXPECTED = [
    'GEN_DTC','VEHICLE_EVENT_HARSH_ACCEL','VEHICLE_EVENT_HARSH_DECEL',
    'VEHICLE_EVENT_HARSH_RIGHT','VEHICLE_EVENT_HARSH_LEFT','VEHICLE_EVENT_HARSH_IMPACT',
    'VEHICLE_EVENT_CONNECTED','VEHICLE_EVENT_DISCONNECTED',
    'VEHICLE_EVENT_TOWED','VEHICLE_EVENT_TOWED_BREADCRUMB'
  ]

  has_many :driver_behaviors
  has_many :connections
  has_many :trouble_codes
  has_many :levels

  belongs_to :vehicle

  after_create :gather_data, if: Proc.new { |t| t.details['data'].present? }

  def started_at
    DateTime.parse details['startTime']
  end

  def ended_at
    DateTime.parse details['endTime']
  end

  def duration
    # seconds
    (ended_at - started_at) * 1.day
  end

  def mileage
    details['mileage'].try(:to_f)
  end

  def start_loc
    s = details['startWaypoint']
    "#{s['latitude']},#{s['longitude']}"
  end

  def end_loc
    s = details['endWaypoint']
    "#{s['latitude']},#{s['longitude']}"
  end

  def fuel_cost
     miles = 1.0 / (vehicle.mpg / mileage)
     FuelEconomy.price * miles
  end

  def max_speed
    speeds = details['data'].select{ |d| d["ignitionStatus"] == 'RUNNING' }.map{ |d| d['datum'] }.flatten.select{ |d| d['key'] == 'GEN_SPEED' }.map{ |h| h['value'].to_f }
    speeds.max
  rescue
    20
  end

  def rpm
    temps = details['data'].map{ |d| d['datum'] }.flatten.select{ |d| d['key'] == 'GEN_RPM' }.map{ |h| h['value'].to_f }
    max = temps.max
    avg = temps.sum / temps.size.to_f
    {max: max, avg: avg}
  rescue
    {max: 2000, avg: 2000}
  end

  def idle_time
  end

private

  def gather_data
    details['data'].each do |data|
      data['datum'].each do |datum|
        next unless EXPECTED.include? datum['key'].try(:upcase)
        Notification.klass(datum['key']).create(
          vehicle: vehicle,
          trip: self,
          details: datum
        )
      end
    end
  end

end

# {"trip"=>
#   [{"id"=>1242,
#     "startTime"=>"20141010T145700+0000",
#     "endTime"=>"20141010T150050+0000",
#     "mileage"=>2.312,
#     "startWaypoint"=>{"timestamp"=>"20141010T145700+0000", "latitude"=>37.79422, "longitude"=>-122.39283},
#     "endWaypoint"=>
#      {"timestamp"=>"20141010T150050+0000", "latitude"=>37.805890000000005, "longitude"=>-122.42537000000002},
#     "data"=>
     # [{"id"=>17087,
     #   "timestamp"=>"20141010T150050+0000",
     #   "ignitionStatus"=>"OFF",
     #   "datum"=>
     #    [{"id"=>88302,
     #      "timestamp"=>"20141010T150050+0000",
     #      "key"=>"GEN_VOLTAGE",
     #      "value"=>"13.566005142522044",
     #      "translatedValue"=>"13.566005142522044V"},
     #     {"id"=>88301,
     #      "timestamp"=>"20141010T150050+0000",
     #      "key"=>"GEN_SPEED",
     #      "value"=>"0",
     #      "translatedValue"=>"0 mph"},
     #     {"id"=>88300,
     #      "timestamp"=>"20141010T150050+0000",
     #      "key"=>"GEN_FUELRATE",
     #      "value"=>"1.1629700340563431",
     #      "translatedValue"=>"1.1629700340563431 gph"},
     #     {"id"=>88299,
     #      "timestamp"=>"20141010T150050+0000",
     #      "key"=>"GEN_FUELLEVEL",
     #      "value"=>"84.61778457276523",
     #      "translatedValue"=>"84.61778457276523 %"},
     #     {"id"=>88298,
     #      "timestamp"=>"20141010T150050+0000",
     #      "key"=>"GEN_RPM",
     #      "value"=>"2653.105221851729",
     #      "translatedValue"=>"2653.105221851729"},
     #     {"id"=>88297,
     #      "timestamp"=>"20141010T150050+0000",
     #      "key"=>"GEN_TRIP_MILEAGE",
     #      "value"=>"2.312",
     #      "translatedValue"=>"2 miles"},
     #     {"id"=>88296,
     #      "timestamp"=>"20141010T150050+0000",
     #      "key"=>"GEN_NEAREST_ADDRESS",
     #      "value"=>"3200-3236 Van Ness Avenue, San Francisco, CA 94109, USA",
     #      "translatedValue"=>"3200-3236 Van Ness Avenue, San Francisco, CA 94109, USA"},
     #     {"id"=>88295,
     #      "timestamp"=>"20141010T150050+0000",
     #      "key"=>"GEN_WAYPOINT",
     #      "value"=>"37.805890000000005,-122.42537000000002",
     #      "translatedValue"=>"37.805890000000005,-122.42537000000002"}]},
#       {"id"=>17085,
#        "timestamp"=>"20141010T150019+0000",
#        "ignitionStatus"=>"RUNNING",
#        "datum"=>
#         [{"id"=>88294,
#           "timestamp"=>"20141010T150019+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"14.48647360492032",
#           "translatedValue"=>"14.48647360492032V"},
#          {"id"=>88291,
#           "timestamp"=>"20141010T150019+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"34.601638433523476",
#           "translatedValue"=>"34.601638433523476 mph"},
#          {"id"=>88288,
#           "timestamp"=>"20141010T150019+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"0.8954491744516417",
#           "translatedValue"=>"0.8954491744516417 gph"},
#          {"id"=>88287,
#           "timestamp"=>"20141010T150019+0000",
#           "key"=>"GEN_FUELLEVEL",
#           "value"=>"59.10889863152988",
#           "translatedValue"=>"59.10889863152988 %"},
#          {"id"=>88284,
#           "timestamp"=>"20141010T150019+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"1943.7158606480807",
#           "translatedValue"=>"1943.7158606480807"},
#          {"id"=>88283,
#           "timestamp"=>"20141010T150019+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"801-851 Bay Street, San Francisco, CA 94109, USA",
#           "translatedValue"=>"801-851 Bay Street, San Francisco, CA 94109, USA"},
#          {"id"=>88281,
#           "timestamp"=>"20141010T150019+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.804730000000006,-122.42077",
#           "translatedValue"=>"37.804730000000006,-122.42077"}]},
#       {"id"=>17086,
#        "timestamp"=>"20141010T150019+0000",
#        "ignitionStatus"=>"RUNNING",
#        "datum"=>
#         [{"id"=>88293,
#           "timestamp"=>"20141010T150019+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"14.48647360492032",
#           "translatedValue"=>"14.48647360492032V"},
#          {"id"=>88292,
#           "timestamp"=>"20141010T150019+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"34.601638433523476",
#           "translatedValue"=>"34.601638433523476 mph"},
#          {"id"=>88290,
#           "timestamp"=>"20141010T150019+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"0.8954491744516417",
#           "translatedValue"=>"0.8954491744516417 gph"},
#          {"id"=>88289,
#           "timestamp"=>"20141010T150019+0000",
#           "key"=>"GEN_FUELLEVEL",
#           "value"=>"59.10889863152988",
#           "translatedValue"=>"59.10889863152988 %"},
#          {"id"=>88286,
#           "timestamp"=>"20141010T150019+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"1943.7158606480807",
#           "translatedValue"=>"1943.7158606480807"},
#          {"id"=>88285,
#           "timestamp"=>"20141010T150019+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"801-851 Bay Street, San Francisco, CA 94109, USA",
#           "translatedValue"=>"801-851 Bay Street, San Francisco, CA 94109, USA"},
#          {"id"=>88282,
#           "timestamp"=>"20141010T150019+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.804730000000006,-122.42077",
#           "translatedValue"=>"37.804730000000006,-122.42077"}]},
#       {"id"=>17084,
#        "timestamp"=>"20141010T145915+0000",
#        "ignitionStatus"=>"RUNNING",
#        "datum"=>
#         [{"id"=>88280,
#           "timestamp"=>"20141010T145915+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"13.730070072924718",
#           "translatedValue"=>"13.730070072924718V"},
#          {"id"=>88279,
#           "timestamp"=>"20141010T145915+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"26.456990302540362",
#           "translatedValue"=>"26.456990302540362 mph"},
#          {"id"=>88278,
#           "timestamp"=>"20141010T145915+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"1.9362251410493627",
#           "translatedValue"=>"1.9362251410493627 gph"},
#          {"id"=>88277,
#           "timestamp"=>"20141010T145915+0000",
#           "key"=>"GEN_FUELLEVEL",
#           "value"=>"90.05235834629275",
#           "translatedValue"=>"90.05235834629275 %"},
#          {"id"=>88276,
#           "timestamp"=>"20141010T145915+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"2293.7043006997555",
#           "translatedValue"=>"2293.7043006997555"},
#          {"id"=>88275,
#           "timestamp"=>"20141010T145915+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"99 Bay Street, San Francisco, CA 94133, USA",
#           "translatedValue"=>"99 Bay Street, San Francisco, CA 94133, USA"},
#          {"id"=>88274,
#           "timestamp"=>"20141010T145915+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.806270000000005,-122.40858000000001",
#           "translatedValue"=>"37.806270000000005,-122.40858000000001"}]},
#       {"id"=>17083,
#        "timestamp"=>"20141010T145800+0000",
#        "ignitionStatus"=>"RUNNING",
#        "datum"=>
#         [{"id"=>88273,
#           "timestamp"=>"20141010T145800+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"13.901347202481702",
#           "translatedValue"=>"13.901347202481702V"},
#          {"id"=>88272,
#           "timestamp"=>"20141010T145800+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"31.970758449751884",
#           "translatedValue"=>"31.970758449751884 mph"},
#          {"id"=>88271,
#           "timestamp"=>"20141010T145800+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"0.5645651920931414",
#           "translatedValue"=>"0.5645651920931414 gph"},
#          {"id"=>88270,
#           "timestamp"=>"20141010T145800+0000",
#           "key"=>"GEN_FUELLEVEL",
#           "value"=>"35.32773228944279",
#           "translatedValue"=>"35.32773228944279 %"},
#          {"id"=>88269,
#           "timestamp"=>"20141010T145800+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"1815.1617902796715",
#           "translatedValue"=>"1815.1617902796715"},
#          {"id"=>88268,
#           "timestamp"=>"20141010T145800+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"700 The Embarcadero, San Francisco, CA 94111, USA",
#           "translatedValue"=>"700 The Embarcadero, San Francisco, CA 94111, USA"},
#          {"id"=>88267,
#           "timestamp"=>"20141010T145800+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.801120000000004,-122.39916000000001",
#           "translatedValue"=>"37.801120000000004,-122.39916000000001"}]},
#       {"id"=>17082,
#        "timestamp"=>"20141010T145700+0000",
#        "ignitionStatus"=>"ON",
#        "datum"=>
#         [{"id"=>88266,
#           "timestamp"=>"20141010T145700+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"13.141474312753417",
#           "translatedValue"=>"13.141474312753417V"},
#          {"id"=>88265,
#           "timestamp"=>"20141010T145700+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"0",
#           "translatedValue"=>"0 mph"},
#          {"id"=>88264,
#           "timestamp"=>"20141010T145700+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"1.2112436660099775",
#           "translatedValue"=>"1.2112436660099775 gph"},
#          {"id"=>88263,
#           "timestamp"=>"20141010T145700+0000",
#           "key"=>"GEN_FUELLEVEL",
#           "value"=>"85.2128088939935",
#           "translatedValue"=>"85.2128088939935 %"},
#          {"id"=>88262,
#           "timestamp"=>"20141010T145700+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"3584.197192499414",
#           "translatedValue"=>"3584.197192499414"},
#          {"id"=>88261,
#           "timestamp"=>"20141010T145700+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"40 The Embarcadero, San Francisco, CA 94107, USA",
#           "translatedValue"=>"40 The Embarcadero, San Francisco, CA 94107, USA"},
#          {"id"=>88260,
#           "timestamp"=>"20141010T145700+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.79422,-122.39283",
#           "translatedValue"=>"37.79422,-122.39283"}]}]},
#    {"id"=>1243,
#     "startTime"=>"20141010T145700+0000",
#     "endTime"=>"20141010T150553+0000",
#     "mileage"=>8.13437,
#     "startWaypoint"=>{"timestamp"=>"20141010T145700+0000", "latitude"=>37.80595, "longitude"=>-122.42557000000001},
#     "endWaypoint"=>{"timestamp"=>"20141010T150553+0000", "latitude"=>37.71305, "longitude"=>-122.38759},
#     "data"=>
#      [{"id"=>17097,
#        "timestamp"=>"20141010T150553+0000",
#        "ignitionStatus"=>"OFF",
#        "datum"=>
#         [{"id"=>88363,
#           "timestamp"=>"20141010T150553+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"13.731983175268397",
#           "translatedValue"=>"13.731983175268397V"},
#          {"id"=>88362,
#           "timestamp"=>"20141010T150553+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"0",
#           "translatedValue"=>"0 mph"},
#          {"id"=>88361,
#           "timestamp"=>"20141010T150553+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"0.5254589412361383",
#           "translatedValue"=>"0.5254589412361383 gph"},
#          {"id"=>88360,
#           "timestamp"=>"20141010T150553+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"1527.8824865818024",
#           "translatedValue"=>"1527.8824865818024"},
#          {"id"=>88359,
#           "timestamp"=>"20141010T150553+0000",
#           "key"=>"GEN_TRIP_MILEAGE",
#           "value"=>"8.13437",
#           "translatedValue"=>"8 miles"},
#          {"id"=>88358,
#           "timestamp"=>"20141010T150553+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"Candlestick Park, San Francisco, CA 94124, USA",
#           "translatedValue"=>"Candlestick Park, San Francisco, CA 94124, USA"},
#          {"id"=>88357,
#           "timestamp"=>"20141010T150553+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.71305,-122.38759",
#           "translatedValue"=>"37.71305,-122.38759"}]},
#       {"id"=>17096,
#        "timestamp"=>"20141010T150520+0000",
#        "ignitionStatus"=>"RUNNING",
#        "datum"=>
#         [{"id"=>88356,
#           "timestamp"=>"20141010T150520+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"14.104896455770358",
#           "translatedValue"=>"14.104896455770358V"},
#          {"id"=>88355,
#           "timestamp"=>"20141010T150520+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"50.803483242634684",
#           "translatedValue"=>"50.803483242634684 mph"},
#          {"id"=>88354,
#           "timestamp"=>"20141010T150520+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"1.8011613991111517",
#           "translatedValue"=>"1.8011613991111517 gph"},
#          {"id"=>88353,
#           "timestamp"=>"20141010T150520+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"2664.5777663215995",
#           "translatedValue"=>"2664.5777663215995"},
#          {"id"=>88352,
#           "timestamp"=>"20141010T150520+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"970 Ingerson Avenue, San Francisco, CA 94124, USA",
#           "translatedValue"=>"970 Ingerson Avenue, San Francisco, CA 94124, USA"},
#          {"id"=>88351,
#           "timestamp"=>"20141010T150520+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.718790000000006,-122.39241000000001",
#           "translatedValue"=>"37.718790000000006,-122.39241000000001"}]},
#       {"id"=>17095,
#        "timestamp"=>"20141010T150419+0000",
#        "ignitionStatus"=>"RUNNING",
#        "datum"=>
#         [{"id"=>88350,
#           "timestamp"=>"20141010T150419+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"13.76367736782413",
#           "translatedValue"=>"13.76367736782413V"},
#          {"id"=>88349,
#           "timestamp"=>"20141010T150419+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"54.04527210397646",
#           "translatedValue"=>"54.04527210397646 mph"},
#          {"id"=>88348,
#           "timestamp"=>"20141010T150419+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"1.0663504325784743",
#           "translatedValue"=>"1.0663504325784743 gph"},
#          {"id"=>88347,
#           "timestamp"=>"20141010T150419+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"1686.7028861306608",
#           "translatedValue"=>"1686.7028861306608"},
#          {"id"=>88346,
#           "timestamp"=>"20141010T150419+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"Bayshore Freeway, San Francisco, CA 94134, USA",
#           "translatedValue"=>"Bayshore Freeway, San Francisco, CA 94134, USA"},
#          {"id"=>88345,
#           "timestamp"=>"20141010T150419+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.71875,-122.39996000000001",
#           "translatedValue"=>"37.71875,-122.39996000000001"}]},
#       {"id"=>17094,
#        "timestamp"=>"20141010T150317+0000",
#        "ignitionStatus"=>"RUNNING",
#        "datum"=>
#         [{"id"=>88344,
#           "timestamp"=>"20141010T150317+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"13.989006553660147",
#           "translatedValue"=>"13.989006553660147V"},
#          {"id"=>88343,
#           "timestamp"=>"20141010T150317+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"52.404269764665514",
#           "translatedValue"=>"52.404269764665514 mph"},
#          {"id"=>88342,
#           "timestamp"=>"20141010T150317+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"2.203749199397862",
#           "translatedValue"=>"2.203749199397862 gph"},
#          {"id"=>88341,
#           "timestamp"=>"20141010T150317+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"1120.3188337385654",
#           "translatedValue"=>"1120.3188337385654"},
#          {"id"=>88340,
#           "timestamp"=>"20141010T150317+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"Bayshore Freeway, San Francisco, CA 94134, USA",
#           "translatedValue"=>"Bayshore Freeway, San Francisco, CA 94134, USA"},
#          {"id"=>88339,
#           "timestamp"=>"20141010T150317+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.73205,-122.40499000000001",
#           "translatedValue"=>"37.73205,-122.40499000000001"}]},
#       {"id"=>17093,
#        "timestamp"=>"20141010T150214+0000",
#        "ignitionStatus"=>"RUNNING",
#        "datum"=>
#         [{"id"=>88338,
#           "timestamp"=>"20141010T150214+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"13.750571771874093",
#           "translatedValue"=>"13.750571771874093V"},
#          {"id"=>88337,
#           "timestamp"=>"20141010T150214+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"49.447831213474274",
#           "translatedValue"=>"49.447831213474274 mph"},
#          {"id"=>88336,
#           "timestamp"=>"20141010T150214+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"1.2542060459963977",
#           "translatedValue"=>"1.2542060459963977 gph"},
#          {"id"=>88335,
#           "timestamp"=>"20141010T150214+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"2575.9970010258257",
#           "translatedValue"=>"2575.9970010258257"},
#          {"id"=>88334,
#           "timestamp"=>"20141010T150214+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"Bayshore Freeway, San Francisco, CA 94110, USA",
#           "translatedValue"=>"Bayshore Freeway, San Francisco, CA 94110, USA"},
#          {"id"=>88333,
#           "timestamp"=>"20141010T150214+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.744980000000005,-122.40523",
#           "translatedValue"=>"37.744980000000005,-122.40523"}]},
#       {"id"=>17092,
#        "timestamp"=>"20141010T150111+0000",
#        "ignitionStatus"=>"RUNNING",
#        "datum"=>
#         [{"id"=>88332,
#           "timestamp"=>"20141010T150111+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"14.497314817854203",
#           "translatedValue"=>"14.497314817854203V"},
#          {"id"=>88331,
#           "timestamp"=>"20141010T150111+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"45.145601253025234",
#           "translatedValue"=>"45.145601253025234 mph"},
#          {"id"=>88330,
#           "timestamp"=>"20141010T150111+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"2.4941149912774563",
#           "translatedValue"=>"2.4941149912774563 gph"},
#          {"id"=>88329,
#           "timestamp"=>"20141010T150111+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"1278.105251956731",
#           "translatedValue"=>"1278.105251956731"},
#          {"id"=>88328,
#           "timestamp"=>"20141010T150111+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"Bayshore Freeway, San Francisco, CA 94110, USA",
#           "translatedValue"=>"Bayshore Freeway, San Francisco, CA 94110, USA"},
#          {"id"=>88327,
#           "timestamp"=>"20141010T150111+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.758190000000006,-122.40505000000002",
#           "translatedValue"=>"37.758190000000006,-122.40505000000002"}]},
#       {"id"=>17091,
#        "timestamp"=>"20141010T150009+0000",
#        "ignitionStatus"=>"RUNNING",
#        "datum"=>
#         [{"id"=>88326,
#           "timestamp"=>"20141010T150009+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"13.617628572043031",
#           "translatedValue"=>"13.617628572043031V"},
#          {"id"=>88325,
#           "timestamp"=>"20141010T150009+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"46.39584368560463",
#           "translatedValue"=>"46.39584368560463 mph"},
#          {"id"=>88324,
#           "timestamp"=>"20141010T150009+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"1.863652016967535",
#           "translatedValue"=>"1.863652016967535 gph"},
#          {"id"=>88323,
#           "timestamp"=>"20141010T150009+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"2040.4475438408554",
#           "translatedValue"=>"2040.4475438408554"},
#          {"id"=>88322,
#           "timestamp"=>"20141010T150009+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"10th Street & Bryant Street, San Francisco, CA 94103, USA",
#           "translatedValue"=>"10th Street & Bryant Street, San Francisco, CA 94103, USA"},
#          {"id"=>88321,
#           "timestamp"=>"20141010T150009+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.77019000000001,-122.40896000000001",
#           "translatedValue"=>"37.77019000000001,-122.40896000000001"}]},
#       {"id"=>17090,
#        "timestamp"=>"20141010T145909+0000",
#        "ignitionStatus"=>"RUNNING",
#        "datum"=>
#         [{"id"=>88320,
#           "timestamp"=>"20141010T145909+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"14.137528484454378",
#           "translatedValue"=>"14.137528484454378V"},
#          {"id"=>88319,
#           "timestamp"=>"20141010T145909+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"45.96242133760825",
#           "translatedValue"=>"45.96242133760825 mph"},
#          {"id"=>88318,
#           "timestamp"=>"20141010T145909+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"0.7298270352184772",
#           "translatedValue"=>"0.7298270352184772 gph"},
#          {"id"=>88317,
#           "timestamp"=>"20141010T145909+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"2416.2369440309703",
#           "translatedValue"=>"2416.2369440309703"},
#          {"id"=>88316,
#           "timestamp"=>"20141010T145909+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"301 Van Ness Avenue, San Francisco, CA 94102, USA",
#           "translatedValue"=>"301 Van Ness Avenue, San Francisco, CA 94102, USA"},
#          {"id"=>88315,
#           "timestamp"=>"20141010T145909+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.77825,-122.41998000000001",
#           "translatedValue"=>"37.77825,-122.41998000000001"}]},
#       {"id"=>17089,
#        "timestamp"=>"20141010T145804+0000",
#        "ignitionStatus"=>"RUNNING",
#        "datum"=>
#         [{"id"=>88314,
#           "timestamp"=>"20141010T145804+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"13.047700072289445",
#           "translatedValue"=>"13.047700072289445V"},
#          {"id"=>88313,
#           "timestamp"=>"20141010T145804+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"46.22203938663006",
#           "translatedValue"=>"46.22203938663006 mph"},
#          {"id"=>88312,
#           "timestamp"=>"20141010T145804+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"1.4914006940089166",
#           "translatedValue"=>"1.4914006940089166 gph"},
#          {"id"=>88311,
#           "timestamp"=>"20141010T145804+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"2016.420220490545",
#           "translatedValue"=>"2016.420220490545"},
#          {"id"=>88310,
#           "timestamp"=>"20141010T145804+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"1801 Van Ness Avenue, San Francisco, CA 94109, USA",
#           "translatedValue"=>"1801 Van Ness Avenue, San Francisco, CA 94109, USA"},
#          {"id"=>88309,
#           "timestamp"=>"20141010T145804+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.792170000000006,-122.42277000000001",
#           "translatedValue"=>"37.792170000000006,-122.42277000000001"}]},
#       {"id"=>17088,
#        "timestamp"=>"20141010T145700+0000",
#        "ignitionStatus"=>"ON",
#        "datum"=>
#         [{"id"=>88308,
#           "timestamp"=>"20141010T145700+0000",
#           "key"=>"GEN_VOLTAGE",
#           "value"=>"13.010930658667348",
#           "translatedValue"=>"13.010930658667348V"},
#          {"id"=>88307,
#           "timestamp"=>"20141010T145700+0000",
#           "key"=>"GEN_SPEED",
#           "value"=>"0",
#           "translatedValue"=>"0 mph"},
#          {"id"=>88306,
#           "timestamp"=>"20141010T145700+0000",
#           "key"=>"GEN_FUELRATE",
#           "value"=>"2.2447151001542807",
#           "translatedValue"=>"2.2447151001542807 gph"},
#          {"id"=>88305,
#           "timestamp"=>"20141010T145700+0000",
#           "key"=>"GEN_RPM",
#           "value"=>"2441.009372472763",
#           "translatedValue"=>"2441.009372472763"},
#          {"id"=>88304,
#           "timestamp"=>"20141010T145700+0000",
#           "key"=>"GEN_NEAREST_ADDRESS",
#           "value"=>"3269 Van Ness Avenue, San Francisco, CA 94109, USA",
#           "translatedValue"=>"3269 Van Ness Avenue, San Francisco, CA 94109, USA"},
#          {"id"=>88303,
#           "timestamp"=>"20141010T145700+0000",
#           "key"=>"GEN_WAYPOINT",
#           "value"=>"37.80595,-122.42557000000001",
#           "translatedValue"=>"37.80595,-122.42557000000001"}]}]}],
#   "totalRecords"=>2,
#   "actions": [
#         {
#             "name": "next",
#             "uri": "https://api.carvoyant.com/v1/api/vehicle/C201200001/trip/?includeData=false&sortOrder=desc&startTime=20130627T090000%2B0000&searchOffset=4&searchLimit=2",
#             "methods": null,
#             "inputs": null
#         },
#         {
#             "name": "previous",
#             "uri": "https://api.carvoyant.com/v1/api/vehicle/C201200001/trip/?includeData=false&sortOrder=desc&startTime=20130627T090000%2B0000&searchLimit=2",
#             "methods": null,
#             "inputs": null
#         }
#     ]
# }
