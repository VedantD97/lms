require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  let!(:user) { create(:user, email: "student@example.com", password: "password123") }

  describe "POST /api/v1/auth/login" do
    it "returns access token and sets refresh cookie" do
      post "/api/v1/auth/login", params: {
        auth: { email: "student@example.com", password: "password123" }
      }

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "access_token")).to be_present
      expect(json_response.dig("data", "user", "email")).to eq("student@example.com")
      expect(response.cookies[Auth::IssueTokens::REFRESH_COOKIE_NAME]).to be_present
    end

    it "returns unauthorized for invalid credentials" do
      post "/api/v1/auth/login", params: {
        auth: { email: "student@example.com", password: "wrongpassword" }
      }

      expect(response).to have_http_status(:unauthorized)
      expect(json_response.dig("error", "code")).to eq("invalid_credentials")
    end
  end

  describe "POST /api/v1/auth/refresh" do
    it "rotates refresh token and returns a new access token" do
      post "/api/v1/auth/login", params: {
        auth: { email: "student@example.com", password: "password123" }
      }
      refresh_token = response.cookies[Auth::IssueTokens::REFRESH_COOKIE_NAME]

      post "/api/v1/auth/refresh", headers: refresh_cookie(refresh_token)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "access_token")).to be_present
      expect(response.cookies[Auth::IssueTokens::REFRESH_COOKIE_NAME]).to be_present
      expect(response.cookies[Auth::IssueTokens::REFRESH_COOKIE_NAME]).not_to eq(refresh_token)
    end
  end

  describe "DELETE /api/v1/auth/logout" do
    it "clears the refresh cookie" do
      post "/api/v1/auth/login", params: {
        auth: { email: "student@example.com", password: "password123" }
      }
      refresh_token = response.cookies[Auth::IssueTokens::REFRESH_COOKIE_NAME]

      delete "/api/v1/auth/logout", headers: refresh_cookie(refresh_token)

      expect(response).to have_http_status(:no_content)
    end
  end
end
