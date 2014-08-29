# # # # #
# Test API responses at http://edmunds.mashery.com/io-docs
# Check ./config/settings.yml to see what the edmunds api_key is
# # # # #

module Edmunds

  def self.images(styleid)
  end

  def self.typical_value(styleid, options={})
    raise 'styleid necessary to talk with API' if styleid.blank?
    Rails.logger.info "some options left out, using default values" if options.blank?

    endpoint = 'v1/api/tmv/tmvservice/calculatetypicallyequippedusedtmv'
    params = {
      styleid: styleid,
      zip: options[:zip] || Settings.locals.zip_code
    }
    doc = fetch(endpoint, params).with_indifferent_access

    return_values(doc[:tmv][:totalWithOptions])
  end

  def self.used_value(styleid, options={})
    raise 'styleid necessary to talk with API' if styleid.blank?
    Rails.logger.info "some options left out, using default values" if options.blank?

    endpoint = 'v1/api/tmv/tmvservice/calculateusedtmv'
    params = {
      styleid: styleid,
      condition: options[:condition] || 'Average', # Outstanding | Clean | Average | Rough | Damaged
      mileage: options[:mileage] || 75000,
      zip: options[:zip] || Settings.locals.zip_code,
      optionid: options[:options] || [], # options: [xxx,xxx]
      colorid: options[:colors] || [] # colors: [xxx]
    }
    doc = fetch(endpoint, params).with_indifferent_access

    return_values(doc[:tmv][:totalWithOptions])
  end

  private

    def self.fetch(endpoint, params={})
      raise 'endpoint necessary to talk with API' if endpoint.blank?
      base = Settings.edmunds.base_url
      params[:fmt] = 'json'
      params[:api_key] = Settings.edmunds.key
      params.slice!(:optionid, :colorid).each_with_object(parameters = []){ |(k,v),o| o << "#{k}=#{v}" }
      params.each{ |k,v| v.each{ |i| parameters << "#{k}=#{i}" } }
      parameters = parameters.join('&')
      HTTParty.get("#{base}/#{endpoint}?#{parameters}")
    end

    def self.return_values(prices={})
      {
        retail: prices[:usedTmvRetail],
        private_party: prices[:usedPrivateParty],
        trade_in: prices[:usedTradeIn]
      }.with_indifferent_access
    end
end