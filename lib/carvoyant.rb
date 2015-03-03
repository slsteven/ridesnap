class Carvoyant
  def initialize
    client = OAuth2::Client.new(
      Settings.carvoyant.client_id,
      Settings.carvoyant.secret,
      site: Settings.carvoyant.base_url
    )
    @carvoyant = client.client_credentials.get_token
    @v = Settings.carvoyant.api_version
  end

  def vehicle(method: :get, id: nil)
    # GET POST
    # /vehicle/
    # /vehicle/{vehicle-id}
    # DELETE
    # /vehicle/{vehicle-id}

    @carvoyant.send(method, "#{@v}/vehicle/#{id}")
  end

  def event_subscription(method: :get, endpoint: :vehicle, endpoint_id:, subscription_id: nil, event_type: nil)
    # GET DELETE
    # /account/{account-id}/eventSubscription/{subscription-id}
    # /account/{account-id}/eventSubscription/{event-type}/{subscription-id}
    # /vehicle/{vehicle-id}/eventSubscription/{subscription-id}
    # /vehicle/{vehicle-id}/eventSubscription/{event-type}/{subscription-id}
    # POST
    # /account/{account-id}/eventSubscription/{event-type}
    # /vehicle/{vehicle-id}/eventSubscription/{event-type}

    event_type.prepend('/') if event_type.present?
    @carvoyant.send(method, "#{@v}/#{endpoint}/#{endpoint_id}/eventSubscription#{event_type}/#{subscription_id}")
      # "minimumTime": 0,
      # "postUrl": "https://test.carvoyant.com/notify",
      # "postHeaders": {
      #   "Authorization": "Bearer asdfqwerzxcv",
      #   "X-Sample-Headers": "Some custom value"
      # },
      # "notificationPeriod": "CONTINUOUS"
  end

  def event_notification(method: :get, endpoint: :vehicle, endpoint_id:, subscription_id: nil, notification_id: nil, event_type: nil)
    # /account/{account-id}/eventNotification/{notification-id}
    # /account/{account-id}/eventNotification/{event-type}/{notification-id}
    # /account/{account-id}/eventSubscription/{subscription-id}/eventNotification/{notification-id}
    # /account/{account-id}/eventSubscription/{subscription-id}/eventNotification/{event-type}/{notification-id}
    # /vehicle/{vehicle-id}/eventNotification/{notification-id}
    # /vehicle/{vehicle-id}/eventNotification/{event-type}/{notification-id}
    # /vehicle/{vehicle-id}/eventSubscription/{subscription-id}/eventNotification/{notification-id}
    # /vehicle/{vehicle-id}/eventSubscription/{subscription-id}/eventNotification/{event-type}/{notification-id}

    event_type.prepend('/') if event_type.present?
    sub = subscription_id.present? ? "/eventSubscription/#{subscription_id}" : ''
    @carvoyant.send(method, "#{@v}/#{endpoint}/#{endpoint_id}#{sub}/eventNotification#{event_type}/#{notification_id}")
  end

end