module Location
  def self.from_zip(code:)
    # https://developers.google.com/maps/documentation/geocoding/
    loc = HTTParty.get "http://maps.googleapis.com/maps/api/geocode/json?address=#{code}&sensor=false"
    result = loc['results'][0]
    {
         city: result['address_components'][1]['long_name'],
        state: result['address_components'][3]['long_name'],
     zip_code: code,
      country: result['address_components'][4]['long_name'],
      lat_lng: "#{result['geometry']['location']['lat']},#{result['geometry']['location']['lng']}"
    }
  rescue
    {}
  end

  def self.places(query:, lat_lng:)
    # https://developers.google.com/maps/documentation/javascript/places
    # https://developers.google.com/places/documentation/supported_types
    types = %w(car_dealer)
    radius = 32200 # meters, or about 20 miles
    results = HTTParty.get "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{lat_lng}&radius=#{radius}&types=#{types.join(',')}&keyword=#{query}&sensor=false&key=#{Settings.google.api_key}"
    results['results']
  rescue
    []
  end
end