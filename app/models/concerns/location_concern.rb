module LocationConcern
  extend ActiveSupport::Concern

  def location
    @loc ||= Location.from_zip code: self.zip_code
  end

  def city
    self.location[:city]
  end

  def state
    self.location[:state]
  end

  def zip_code
    super
  end

  def country
    self.location[:country]
  end

  def lat_lng
    self.location[:lat_lng]
  end
end