class Vehicle < ActiveRecord::Base
  include AASM

  aasm column: 'status' do

  end

  def location
    loc = HTTParty.get("http://maps.googleapis.com/maps/api/geocode/json?address=#{zip_code}&sensor=false")
    return {} unless loc['status'] == 'OK'
    {
         city: loc['results'][0]['address_components'][1]['long_name'],
        state: loc['results'][0]['address_components'][3]['long_name'],
      country: loc['results'][0]['address_components'][4]['long_name']
    }
  end
end