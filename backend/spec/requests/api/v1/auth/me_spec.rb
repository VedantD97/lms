require "rails_helper"

RSpec.describe "Api::V1::Auth::Me", type: :request do
  let(:user) { create(:user) }

  describe "GET /api/v1/auth/me" do
    it "returns the current user profile" do
      get "/api/v1/auth/me", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "uuid")).to eq(user.uuid)
      expect(json_response.dig("data", "email")).to eq(user.email)
    end

    it "returns unauthorized without a token" do
      get "/api/v1/auth/me"

      expect(response).to have_http_status(:unauthorized)
      expect(json_response.dig("error", "code")).to eq("unauthorized")
    end
  end
end
