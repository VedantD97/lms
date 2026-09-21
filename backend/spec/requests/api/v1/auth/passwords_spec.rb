require "rails_helper"

RSpec.describe "Api::V1::Auth::Passwords", type: :request do
  let!(:user) { create(:user, email: "reset@example.com") }

  describe "POST /api/v1/auth/forgot_password" do
    it "accepts the request and enqueues email" do
      expect {
        post "/api/v1/auth/forgot_password", params: { auth: { email: user.email } }
      }.to have_enqueued_mail(PasswordResetMailer, :reset_instructions)

      expect(response).to have_http_status(:ok)
    end

    it "returns success even when email is unknown" do
      post "/api/v1/auth/forgot_password", params: { auth: { email: "missing@example.com" } }

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/v1/auth/reset_password" do
    it "resets the password with a valid token" do
      raw_token = SecureRandom.urlsafe_base64(32)
      user.password_reset_tokens.create!(
        token_digest: PasswordResetToken.digest(raw_token),
        expires_at: 1.hour.from_now
      )

      post "/api/v1/auth/reset_password", params: {
        auth: {
          token: raw_token,
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }

      expect(response).to have_http_status(:ok)
      expect(user.reload.authenticate("newpassword123")).to be_truthy
    end
  end
end
