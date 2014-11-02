module LocationConcern
  extend ActiveSupport::Concern

  def location
    Location.from_zip self.zip_code
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
end