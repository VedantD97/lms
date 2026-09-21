require "rails_helper"

RSpec.describe "Rate limiting", type: :request do
  let!(:user) { create(:user, email: "student@example.com", password: "password123") }

  describe "POST /api/v1/auth/login" do
    it "returns 429 after too many failed attempts from the same IP" do
      5.times do
        post "/api/v1/auth/login", params: {
          auth: { email: "student@example.com", password: "wrongpassword" }
        }
        expect(response).to have_http_status(:unauthorized)
      end

      post "/api/v1/auth/login", params: {
        auth: { email: "student@example.com", password: "wrongpassword" }
      }

      expect(response).to have_http_status(:too_many_requests)
      expect(json_response.dig("error", "code")).to eq("rate_limit_exceeded")
      expect(response.headers["Retry-After"]).to be_present
    end
  end
end

RSpec.describe "Security headers", type: :request do
  it "includes OWASP recommended headers" do
    get "/api/v1/health"

    expect(response.headers["X-Frame-Options"]).to eq("DENY")
    expect(response.headers["X-Content-Type-Options"]).to eq("nosniff")
    expect(response.headers["Referrer-Policy"]).to eq("strict-origin-when-cross-origin")
    expect(response.headers["Content-Security-Policy"]).to include("frame-ancestors 'none'")
  end
end
