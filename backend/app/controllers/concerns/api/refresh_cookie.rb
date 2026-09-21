module Api
  module RefreshCookie
    extend ActiveSupport::Concern

    REFRESH_COOKIE_NAME = Auth::IssueTokens::REFRESH_COOKIE_NAME

    private

    def set_refresh_token_cookie(raw_token)
      cookies[REFRESH_COOKIE_NAME] = {
        value: raw_token,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax,
        expires: Rails.configuration.x.refresh_token_ttl.from_now,
        path: "/api/v1/auth"
      }
    end

    def clear_refresh_token_cookie
      cookies.delete(REFRESH_COOKIE_NAME, path: "/api/v1/auth")
    end

    def refresh_token_from_cookie
      cookies[REFRESH_COOKIE_NAME]
    end
  end
end
