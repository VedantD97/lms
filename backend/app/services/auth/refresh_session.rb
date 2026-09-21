module Auth
  class RefreshSession
    def initialize(raw_refresh_token:, request:)
      @raw_refresh_token = raw_refresh_token
      @request = request
    end

    def call
      if raw_refresh_token.blank?
        return ServiceResult::Base.failure(
          errors: [ { field: "base", message: "Refresh token is missing" } ],
          error_code: "invalid_token"
        )
      end

      refresh_token = RefreshToken.active.find_by(
        token_digest: RefreshToken.digest(raw_refresh_token)
      )

      unless refresh_token
        return ServiceResult::Base.failure(
          errors: [ { field: "base", message: "Invalid or expired refresh token" } ],
          error_code: "invalid_token"
        )
      end

      user = refresh_token.user
      refresh_token.revoke!

      Auth::IssueTokens.new(user: user, request: request).call
    end

    private

    attr_reader :raw_refresh_token, :request
  end
end
