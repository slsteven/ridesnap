module Api::Carvoyant
  # # # # #
  # Interaction with the Carvoyant API
  # # # # #

  def account(method: :get, user_id: nil, **params)
    # GET POST
    # /account/
    # /account/{account-id}
    # DELETE
    # /account/{account-id}

    res = get_token.send(method.to_sym, "#{Settings.carvoyant.api_version}/account/#{user_id}", opts(params))

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

    JSON.parse res.body
  end

  def vehicle(method: :get, vehicle_id: nil, **params)
    # GET POST
    # /vehicle/
    # /vehicle/{vehicle-id}
    # DELETE
    # /vehicle/{vehicle-id}

    res = get_token.send(method.to_sym, "#{Settings.carvoyant.api_version}/vehicle/#{vehicle_id}", opts(params))

      # SAMPLE POST PARAMS
      # # # # # # # # # #
      # vehicleId: 3, # exclude the id to create a new record, include to update
      # name: "1999 Jeep Wrangler",
      # deviceId: "C201200001",
      # vin: "12345678912345678",
      # label: "Jeep",
      # mileage: 159774,
      # lastWaypoint: {
      #   timestamp: "20140116T152440+0000",
      #   latitude: 28.088505,
      #   longitude: -82.578467
      # },
      # running: true,
      # lastRunningTimestamp: "20140116T151952+0000",
      # year: "2006",
      # make: "Jeep",
      # model: "Wrangler LJ"

    JSON.parse res.body
  end

  def trip(vehicle_id:, trip_id: nil, **params)
    # GET
    # /vehicle/{vehicle-id}/trip/?includeData={true|false}&startTime={startTime}&endTime={endTime}
    # /vehicle/{vehicle-id}/trip/{trip-id}

    res = get_token.get("#{Settings.carvoyant.api_version}/vehicle/#{vehicle_id}/trip/#{trip_id}", opts(params))

    JSON.parse res.body
  end

  def data_set(method: :get, vehicle_id:, **params)
    # GET POST
    # /vehicle/{vehicle-id}/dataSet/

    res = get_token.send(method.to_sym, "#{Settings.carvoyant.api_version}/vehicle/#{vehicle_id}/dataSet", opts(params))

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

    JSON.parse res.body
  end

  def data_point(vehicle_id:, **params)
    # GET
    # /vehicle/{vehicle-id}/data/
    # /vehicle/{vehicle-id}/data/?key={key-id}
    # /vehicle/{vehicle-id}/data/?mostRecentOnly=true
    res = get_token.get("#{Settings.carvoyant.api_version}/vehicle/#{vehicle_id}/data", opts(params))

    JSON.parse res.body
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
    res = get_token.send(method.to_sym, "#{Settings.carvoyant.api_version}/#{endpoint}/#{endpoint_id}/eventSubscription#{event_type}/#{subscription_id}", opts(params))

      # SAMPLE POST PARAMS
      # # # # # # # # # #
      # minimumTime: 0,
      # postUrl: "https://test.carvoyant.com/notify",
      # notificationPeriod: "CONTINUOUS"

    JSON.parse res.body
  end

  def event_notification(endpoint: :vehicle, endpoint_id:, subscription_id: nil, notification_id: nil, event_type: nil)
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
    res = get_token.get("#{Settings.carvoyant.api_version}/#{endpoint}/#{endpoint_id}#{sub}/eventNotification#{event_type}/#{notification_id}")

    JSON.parse res.body
  end

  def test_event_subscription(vehicle_id:, subscription_id:)
    # GET
    # /test/vehicle/{vehicle-id}/eventSubscription/{subscription-id}

    res = get_token.get("#{Settings.carvoyant.api_version}/test/vehicle/#{vehicle_id}/eventSubscription/#{subscription_id}")

    JSON.parse res.body
  end

private

  def opts(params)
    {
      headers: {'Content-Type' => 'application/json'},
      body: params.to_json
    }
  end

end