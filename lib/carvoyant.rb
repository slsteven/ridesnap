class Carvoyant
  def initialize
    client = OAuth2::Client.new(
      Settings.carvoyant.client_id,
      Settings.carvoyant.secret,
      site: "#{Settings.carvoyant.base_url}/OAuth/authorize"
    )
    # redir = "#{request.protocol}#{request.host_with_port}/auth/carvoyant/callback"
    redir = "https://ridesnap.dev/auth/carvoyant/callback"
    code = client.auth_code.authorize_url(redirect_uri: redir)
    @carvoyant = client.auth_code.get_token(code, redirect_uri: redir, headers: {})
    response = @carvoyant.get('/api/resource')
    response.class.name
  end

  def fetch(endpoint)
    raise 'endpoint necessary to talk with API' if endpoint.blank?
    base = Settings.carvoyant.base_url
    headers = {
      'Authorization'=> "Bearer #{}",
    }
    result = HTTParty.get("#{base}/#{endpoint}", headers: headers)
  end
end