# # # # #
# Test API responses at http://edmunds.mashery.com/io-docs
# Check ./config/settings.yml to see what the edmunds api_key is
# # # # #

module Edmunds

  def self.images(styleid)
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
    doc[:years].each_with_object(years=[]){ |h,o| o << h[:year] }
    years.reverse
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

  private

    def self.fetch(endpoint, params={})
      raise 'endpoint necessary to talk with API' if endpoint.blank?
      base = Settings.edmunds.base_url
      params[:fmt] = 'json'
      params[:api_key] = Settings.edmunds.key
      params.slice!(:optionid, :colorid).each_with_object(parameters = []){ |(k,v),o| o << "#{k}=#{v}" }
      params.each{ |k,v| v.delete(' ').split(',').each{ |i| parameters << "#{k}=#{i}" } }
      parameters = parameters.join('&')
      HTTParty.get("#{base}/#{endpoint}?#{parameters}").with_indifferent_access
    end

    def self.return_values(prices={})
      {
        retail: prices[:usedTmvRetail],
        private_party: prices[:usedPrivateParty],
        trade_in: prices[:usedTradeIn]
      }
    end
end