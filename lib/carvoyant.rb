# http://docs.carvoyant.com/en/latest/api-reference/index.html

# TODO SORTING AND PAGING

class Carvoyant

  def initialize
    client = OAuth2::Client.new(
      Settings.carvoyant.client_id,
      Settings.carvoyant.secret,
      site: Settings.carvoyant.base_url,
      token_url: Settings.carvoyant.token_url
    )
    @carvoyant = client.client_credentials.get_token
    @v = Settings.carvoyant.api_version
  end

  def account(method: :get, user_id: nil, **params)
    # GET POST
    # /account/
    # /account/{account-id}
    # DELETE
    # /account/{account-id}
    @carvoyant.send(method, "#{@v}/account/#{user_id}", params.deep_stringify_keys)
      # SAMPLE POST PARAMS
      # # # # # # # # # #
      # id: 3, # exclude the id to create a new record, include to update
      # firstName: "Speed",
      # lastName: "Racer",
      # username: "speedracer",
      # password: "foobar",
      # dateCreated: "20121130T144013+0000",
      # email: "speedracer@noemail.com",
      # zipcode: "33635",
      # phone: "8135551212",
      # timeZone: "America/New_York",
      # preferredContact: "PHONE",
      # accessToken: {
      #   code: "2f2w4ae6mmbvrdk94feen2gy"
      # }
  end

  def vehicle(method: :get, vehicle_id: nil, **params)
    # GET POST
    # /vehicle/
    # /vehicle/{vehicle-id}
    # DELETE
    # /vehicle/{vehicle-id}

    @carvoyant.send(method, "#{@v}/vehicle/#{vehicle_id}", params.deep_stringify_keys)
      # SAMPLE POST PARAMS
      # # # # # # # # # #
      # vehicleId: 3, # exclude the id to create a new record, include to update
      # name: "1999 Jeep Wrangler",
      # deviceId: "C201200001",
      # vin: "12345678912345678",
      # label: "Custom dune buggy",
      # mileage: 159774,
      # lastWaypoint: {
      #   timestamp: "20140116T152440+0000",
      #   latitude: 28.088505,
      #   longitude: -82.578467
      # },
      # running: false,
      # lastRunningTimestamp: "20140116T151952+0000",
      # year: "1999",
      # make: "Jeep",
      # model: "Wrangler"
  end

  def trip(method: :get, vehicle_id:, trip_id: nil, **params)
    # GET
    # /vehicle/{vehicle-id}/trip/?includeData={true|false}&startTime={startTime}&endTime={endTime}
    # /vehicle/{vehicle-id}/trip/{trip-id}

    @carvoyant.send(method, "#{@v}/vehicle/#{vehicle_id}/trip/#{trip_id}", params.deep_stringify_keys)
  end

  def data_set(method: :get, vehicle_id:, **params)
    # GET POST
    # /vehicle/{vehicle-id}/dataSet/

    @carvoyant.send(method, "#{@v}/vehicle/#{vehicle_id}/dataSet", params.deep_stringify_keys)
      # SAMPLE POST PARAMS
      # # # # # # # # # #
      # timestamp: "20140811T140444+0000",
      # vin: "123456789ABCDEFGH",
      # deviceId: "C20120000X",
      # ignitionStatus: "ON",
      # datum: [
      #   {
      #     timestamp: "20140811T140444+0000",
      #     key: "GEN_WAYPOINT",
      #     value: "28.027065,-82.588619"
      #   },
      #   {
      #     timestamp: "20140811T140444+0000",
      #     key: "GEN_HEADING",
      #     value: 323
      #   },
      #   {
      #     timestamp: "20140811T140444+0000",
      #     key: "GEN_VOLTAGE",
      #     value: "13.6"
      #   }
      # ]
  end

  def data_point(method: :get, vehicle_id:, **params)
    # GET
    # /vehicle/{vehicle-id}/data/
    # /vehicle/{vehicle-id}/data/?key={key-id}
    # /vehicle/{vehicle-id}/data/?mostRecentOnly=true
    @carvoyant.send(method, "#{@v}/vehicle/#{vehicle_id}/data", params.deep_stringify_keys)
  end

  def event_subscription(method: :get, endpoint: :vehicle, endpoint_id:, subscription_id: nil, event_type: nil, **params)
    # GET DELETE
    # /account/{account-id}/eventSubscription/{subscription-id}
    # /account/{account-id}/eventSubscription/{event-type}/{subscription-id}
    # /vehicle/{vehicle-id}/eventSubscription/{subscription-id}
    # /vehicle/{vehicle-id}/eventSubscription/{event-type}/{subscription-id}
    # POST
    # /account/{account-id}/eventSubscription/{event-type}
    # /vehicle/{vehicle-id}/eventSubscription/{event-type}

    event_type.prepend('/') if event_type.present?
    @carvoyant.send(method, "#{@v}/#{endpoint}/#{endpoint_id}/eventSubscription#{event_type}/#{subscription_id}", params.deep_stringify_keys)
      # SAMPLE POST PARAMS
      # # # # # # # # # #
      # minimumTime: 0,
      # postUrl: "https://test.carvoyant.com/notify",
      # notificationPeriod: "CONTINUOUS"
  end

  def event_notification(method: :get, endpoint: :vehicle, endpoint_id:, subscription_id: nil, notification_id: nil, event_type: nil)
    # GET # We will never really be calling this... this endpoint actually posts to our app from Carvoyant
    # /account/{account-id}/eventNotification/{notification-id}
    # /account/{account-id}/eventNotification/{event-type}/{notification-id}
    # /account/{account-id}/eventSubscription/{subscription-id}/eventNotification/{notification-id}
    # /account/{account-id}/eventSubscription/{subscription-id}/eventNotification/{event-type}/{notification-id}
    # /vehicle/{vehicle-id}/eventNotification/{notification-id}
    # /vehicle/{vehicle-id}/eventNotification/{event-type}/{notification-id}
    # /vehicle/{vehicle-id}/eventSubscription/{subscription-id}/eventNotification/{notification-id}
    # /vehicle/{vehicle-id}/eventSubscription/{subscription-id}/eventNotification/{event-type}/{notification-id}

    event_type.prepend('/') if event_type.present?
    sub = subscription_id.present? ? "/eventSubscription/#{subscription_id}" : nil
    @carvoyant.send(method, "#{@v}/#{endpoint}/#{endpoint_id}#{sub}/eventNotification#{event_type}/#{notification_id}")
  end

  def test_event_subscription(method: :get, vehicle_id:, subscription_id:)
    # GET
    # /test/vehicle/{vehicle-id}/eventSubscription/{subscription-id}

    @carvoyant.send(method, "#{@v}/test/vehicle/#{vehicle_id}/eventSubscription/#{subscription_id}")
  end

end