# # # # #
# Test API responses at http://edmunds.mashery.com/io-docs
# Check ./config/settings.yml to see what the edmunds api_key is
# # # # #

module Edmunds

  def self.query_colors(styleid)
    endpoint = "api/vehicle/v2/styles/#{styleid}/colors"
    doc = fetch(endpoint)
    return doc if doc.kind_of? Integer
    doc[:colors].each_with_object(colors={}) do |h,o|
      next unless h[:name]
      o[h[:category].downcase] ||= {}
      o[h[:category].downcase][h[:id]] = { name: h[:name],
                                           primary: h[:colorChips].try(:fetch, :primary, nil).try(:fetch, :hex, nil),
                                           secondary: h[:colorChips].try(:fetch, :secondary, nil).try(:fetch, :hex, nil),
                                           equipped: nil }
    end
    colors
  end

  def self.query_options(styleid)
    endpoint = "api/vehicle/v2/styles/#{styleid}/options"
    doc = fetch(endpoint)
    return doc if doc.kind_of? Integer
    doc[:options].each_with_object(options={}) do |h,o|
      next if ['package', 'additional fees', 'other'].include? h[:category].downcase
      o[h[:category].downcase] ||= {}
      o[h[:category].downcase][h[:id]] = { name: h[:name],
                                           description: h[:description],
                                           availability: h[:availability].downcase,
                                           equipped: nil }
    end
    options
  end

  def self.query_specs(styleid)
    endpoint = "api/vehicle/v2/styles/#{styleid}/equipment"
    doc = fetch(endpoint)
    atts = doc[:equipment].select{ |h| h['name'] == 'Specifications' }[0]['attributes']
    return doc if doc.kind_of? Integer
    atts.each_with_object(equipment={}) do |h,o|
      o[h[:name].downcase] =  h[:value]
    end
    equipment
  end

  def self.query_engines(styleid)
    endpoint = "api/vehicle/v2/styles/#{styleid}/engines"
    doc = fetch(endpoint)
    return doc if doc.kind_of? Integer
    doc[:engines].each_with_object(engines={}) do |h,o|
      o[h[:id]] = { name: "#{h[:size]}L #{h[:configuration]}#{h[:cylinder]}",
                    description: h[:name],
                    availability: h[:availability].downcase,
                    equipped: h[:availability].downcase == 'standard' ? true : nil }
    end
    engines
  end

  def self.query_transmissions(styleid)
    endpoint = "api/vehicle/v2/styles/#{styleid}/transmissions"
    doc = fetch(endpoint)
    return doc if doc.kind_of? Integer
    doc[:transmissions].each_with_object(transmissions={}) do |h,o|
      o[h[:id]] = { name: h[:name],
                    description: "#{h[:numberOfSpeeds]}-speed #{h[:transmissionType].downcase}",
                    availability: h[:availability].downcase,
                    equipped: h[:availability].downcase == 'standard' ? true : nil }
    end
    transmissions
  end

  def self.query_images(styleid, options={})
    raise 'styleid necessary to talk with API' if styleid.blank?

    endpoint = 'v1/api/vehiclephoto/service/findphotosbystyleid'
    options[:styleId] = styleid
    options[:comparator] = 'simple'
    doc = fetch(endpoint, options)
    return doc if doc.kind_of? Integer
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
    return doc if doc.kind_of? Integer
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
    return doc if doc.kind_of? Integer
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
    return doc if doc.kind_of? Integer
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
    return doc if doc.kind_of? Integer
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
    return doc if doc.kind_of? Integer

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
    return doc if doc.kind_of? Integer

    return_values(doc[:tmv][:totalWithOptions])
  end

  def self.vin_to_style(vin)
    raise 'vin necessary to talk with API' if vin.blank?
    endpoint = "api/vehicle/v2/vins/#{vin}"
    doc = fetch(endpoint)
    return {} if doc.kind_of? Integer
    {
      make: doc[:make][:niceName],
      model: doc[:model][:niceName],
      model_pretty: doc[:model][:name],
      year: doc[:years][0][:year],
      style: doc[:years][0][:styles][0][:id],
      description: doc[:years][0][:styles][0][:name]
      # body: doc[:categories][:vehicleStyle].downcase
    }
  rescue
    {}
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
    return result.code unless result.code.to_s[/^2/]
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