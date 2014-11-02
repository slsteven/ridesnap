module Location
  def self.from_zip(code)
    loc = HTTParty.get("http://maps.googleapis.com/maps/api/geocode/json?address=#{code}&sensor=false")
    {
         city: loc['results'][0]['address_components'][1]['long_name'],
        state: loc['results'][0]['address_components'][3]['long_name'],
     zip_code: code,
      country: loc['results'][0]['address_components'][4]['long_name']
    }
  rescue
    {}
  end
end