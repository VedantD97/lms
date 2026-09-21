module Auth
  class RevokeSession
    def initialize(raw_refresh_token:)
      @raw_refresh_token = raw_refresh_token
    end

    def call
      return ServiceResult::Base.success unless raw_refresh_token.present?

      refresh_token = RefreshToken.active.find_by(
        token_digest: RefreshToken.digest(raw_refresh_token)
      )
      refresh_token&.revoke!

      ServiceResult::Base.success
    end

    private

    attr_reader :raw_refresh_token
  end
end
