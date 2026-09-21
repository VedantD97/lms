module Api
  module Authentication
    extend ActiveSupport::Concern

    included do
      attr_reader :current_user
    end

    private

    def authenticate_user!
      @current_user = user_from_access_token

      return if current_user&.active?

      render_error(
        code: "unauthorized",
        message: "Authentication required",
        status: :unauthorized
      )
    end

    def user_from_access_token
      token = bearer_token
      return nil if token.blank?

      payload = JsonWebToken.decode(token)
      return nil if payload.blank?

      User.with_roles.find_by(uuid: payload[:sub])
    end

    def bearer_token
      header = request.headers["Authorization"]
      return nil if header.blank?

      match = header.match(/\ABearer (.+)\z/)
      match&.captures&.first
    end
  end
end
