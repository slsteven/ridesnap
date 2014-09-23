# # # # #
# Test API responses at http://edmunds.mashery.com/io-docs
# Check ./config/settings.yml to see what the edmunds api_key is
# # # # #

module Edmunds

  def self.query_color(styleid)
    endpoint = "api/vehicle/v2/styles/#{styleid}/colors"
    doc = fetch(endpoint)
    interior = {}
    exterior = {}
    doc[:colors].each do |c|
      next unless c[:colorChips] && c[:name]
      if c[:category].downcase == 'exterior'
        exterior[c[:id]] = { name: c[:name],
                             primary: c[:colorChips][:primary].try(:fetch, :hex, nil),
                             secondary: c[:colorChips][:secondary].try(:fetch, :hex, nil) }
      else
        interior[c[:id]] = { name: c[:name],
                             primary: c[:colorChips][:primary].try(:fetch, :hex, nil),
                             secondary: c[:colorChips][:secondary].try(:fetch, :hex, nil) }
      end
    end
    {interior: interior, exterior: exterior}
  end

  def self.query_equipment(styleid)
    endpoint = "api/vehicle/v2/styles/#{styleid}/equipment"
    doc = fetch(endpoint)
    doc[:equipment].each_with_object(options={}) do |h,o|
      o[h[:equipmentType].downcase] ||= {}
      o[h[:equipmentType].downcase][h[:id]] = { name: h[:name],
                                                availability: h[:availability].downcase }
    end
  end

  def self.images(styleid, options={})
    raise 'styleid necessary to talk with API' if styleid.blank?

    endpoint = 'v1/api/vehiclephoto/service/findphotosbystyleid'
    options[:styleId] = styleid
    options[:comparator] = 'simple'
    doc = fetch(endpoint, options)
    imgs = doc[0]['photoSrcs']
    img = imgs.select{ |i| i[/500.jpg$/i] }[0] || imgs[0]
    img = Settings.edmunds.image_url + img
    caption = doc[0]['captionTranscript']
    {image: img, caption: caption}
  end

  def self.query_makes(options={})
    Rails.logger.info "some options left out, using default values" if options.blank?

    endpoint = 'api/vehicle/v2/makes'
    options[:state] ||= 'used'
    options[:view] ||= 'basic'

    doc = fetch(endpoint, options)
    doc[:makes].each_with_object(makes={}){ |h,o| o[h[:niceName]] = h[:name] }
    makes.with_indifferent_access
  end

  def self.query_models(make, options={})
    raise 'make necessary to talk with API' if make.blank?
    Rails.logger.info "some options left out, using default values" if options.blank?

    endpoint = "api/vehicle/v2/#{make}/models"
    options[:state] ||= 'used'
    options[:view] ||= 'basic'

    doc = fetch(endpoint, options)
    doc[:models].each_with_object(models={}){ |h,o| o[h[:niceName]] = h[:name] }
    models.with_indifferent_access
  end

  def self.query_years(make, model, options={})
    raise 'make and model necessary to talk with API' if make.blank? || model.blank?
    Rails.logger.info "some options left out, using default values" if options.blank?

    endpoint = "api/vehicle/v2/#{make}/#{model}/years"
    options[:state] ||= 'used'
    options[:view] ||= 'basic'

    doc = fetch(endpoint, options)
    doc[:years].each_with_object(years={}){ |h,o| o[h[:year]] = h[:year] }
    years.with_indifferent_access
  end

  def self.query_styles(make, model, year, options={})
    raise 'make, model, and year necessary to talk with API' if make.blank? || model.blank? || year.blank?
    Rails.logger.info "some options left out, using default values" if options.blank?

    endpoint = "api/vehicle/v2/#{make}/#{model}/#{year}/styles"
    options[:state] ||= 'used'
    options[:view] ||= 'basic'

    doc = fetch(endpoint, options)
    doc[:styles].each_with_object(styles={}){ |h,o| o[h[:id]] = h[:name] }
    styles.with_indifferent_access
  end

  def self.typical_value(styleid, options={})
    raise 'styleid necessary to talk with API' if styleid.blank?
    Rails.logger.info "some options left out, using default values" if options.blank?

    endpoint = 'v1/api/tmv/tmvservice/calculatetypicallyequippedusedtmv'
    options[:styleid] = styleid
    options[:zip] ||= Settings.locals.zip_code

    doc = fetch(endpoint, options)

    return_values(doc[:tmv][:totalWithOptions])
  end

  def self.used_value(styleid, options={})
    raise 'styleid necessary to talk with API' if styleid.blank?
    Rails.logger.info "some options left out, using default values" if options.blank?

    endpoint = 'v1/api/tmv/tmvservice/calculateusedtmv'
    options[:styleid] = styleid
    options[:condition] ||= 'Average' # Outstanding | Clean | Average | Rough | Damaged
    options[:mileage] ||= 75000
    options[:zip] ||= Settings.locals.zip_code
    # options: 'xxx,xxx' # csv
    # colors: 'xxx' # csv

    doc = fetch(endpoint, options)

    return_values(doc[:tmv][:totalWithOptions])
  end

  def self.vin_to_style(vin)
    raise 'vin necessary to talk with API' if vin.blank?
    endpoint = "api/vehicle/v2/vins/#{vin}"
    doc = fetch(endpoint)
    doc[:years][0][:styles][0][:id] rescue nil
  end

  private

    def self.fetch(endpoint, params={})
      raise 'endpoint necessary to talk with API' if endpoint.blank?
      base = Settings.edmunds.base_url
      params[:fmt] = 'json'
      params[:api_key] = Settings.edmunds.key
      params.slice!(:optionid, :colorid).each_with_object(parameters = []){ |(k,v),o| o << "#{k}=#{v}" }
      params.each{ |k,v| v.delete(' ').split(',').each{ |i| parameters << "#{k}=#{i}" } }
      parameters = parameters.join('&')
      result = HTTParty.get("#{base}/#{endpoint}?#{parameters}")
      result.kind_of?(Hash) ? result.with_indifferent_access : result
    end

    def self.return_values(prices={})
      {
        retail: prices[:usedTmvRetail],
        private_party: prices[:usedPrivateParty],
        trade_in: prices[:usedTradeIn]
      }
    end
end