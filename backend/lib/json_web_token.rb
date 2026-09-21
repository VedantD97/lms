module JsonWebToken
  module_function

  def encode(payload, exp: Rails.configuration.x.jwt_access_token_ttl.from_now)
    payload = payload.dup
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret, "HS256")
  end

  def decode(token)
    body = JWT.decode(token, secret, true, algorithm: "HS256").first
    ActiveSupport::HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def secret
    Rails.configuration.x.jwt_secret
  end
end
