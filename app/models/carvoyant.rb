# == Schema Information
#
# Table name: authentications
#
#  id         :integer          not null, primary key
#  vehicle_id :integer
#  type       :string
#  grant      :string
#  token      :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_authentications_on_type        (type)
#  index_authentications_on_vehicle_id  (vehicle_id)
#

class Carvoyant < Authentication
  # http://docs.carvoyant.com/en/latest/api-reference/index.html
  # TODO SORTING AND PAGING
  include Api::Carvoyant

  after_initialize :defaults

  # # # # #
  # Authentication
  # # # # #

  def client
    OAuth2::Client.new(
      Settings.carvoyant.client_id,
      Settings.carvoyant.secret,
      site: Settings.carvoyant.base_url,
      token_url: Settings.carvoyant.token_path,
      authorize_url: Settings.carvoyant.auth_url
    )
  end

  def auth_url
    case grant
    when 'authorization_code'
      client.auth_code.authorize_url(redirect_uri: Settings.carvoyant.callback_url)
    when 'implicit'
      client.implicit.authorize_url(redirect_uri: Settings.carvoyant.callback_url)
    end
  end

  def get_token(auth_code: nil)
    tok = case grant
    when 'client_credentials'
      client.client_credentials.get_token
    when 'authorization_code'
      if token.present? && !expired?
        OAuth2::AccessToken.from_hash(client, token)
      else
        raise ArgumentError "Token invalid, auth_code cannot be nil" unless auth_code
        client.auth_code.get_token(auth_code, redirect_uri: Settings.carvoyant.callback_url)
      end
    when 'implicit'
      raise ArgumentError "Implicit grant, auth_code cannot be nil" unless auth_code
      OAuth2::AccessToken.from_kvform(client, auth_code)
    end
    self.token = tok.to_hash
    return tok
  end

  def expired?
    DateTime.strptime(token['expires_at'].to_s,'%s') < Time.now.utc
  end

private

  def defaults
    self.grant ||= 'authorization_code'
  end

end
