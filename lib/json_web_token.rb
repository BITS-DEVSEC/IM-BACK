class JsonWebToken
  def self.decode(token)
    JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: "HS256")[0]
  rescue JWT::DecodeError
    nil
  end
end
