module FuelEconomy
  def self.price
    res = HTTParty.get("http://www.fueleconomy.gov/ws/rest/fuelprices")
    res['fuelPrices']['regular'].try(:to_f)
  end
end