module Auth
  class IssueTokens
    REFRESH_COOKIE_NAME = "refresh_token"

    def initialize(user:, request:)
      @user = user
      @request = request
    end

    def call
      access_token = JsonWebToken.encode(
        { sub: user.uuid, roles: user.role_names }
      )

      raw_refresh_token = SecureRandom.urlsafe_base64(32)
      refresh_token = user.refresh_tokens.create!(
        token_digest: RefreshToken.digest(raw_refresh_token),
        expires_at: Rails.configuration.x.refresh_token_ttl.from_now,
        user_agent: request.user_agent,
        ip_address: request.remote_ip
      )

      ServiceResult::Base.success(
        access_token: access_token,
        refresh_token: raw_refresh_token,
        refresh_token_record: refresh_token,
        user: user
      )
    end

    private

    attr_reader :user, :request
  end
end
