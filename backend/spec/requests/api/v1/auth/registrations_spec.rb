require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST /api/v1/auth/register" do
    let(:valid_params) do
      {
        user: {
          email: "newstudent@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "New",
          last_name: "Student"
        }
      }
    end

    it "creates a student user" do
      post "/api/v1/auth/register", params: valid_params

      expect(response).to have_http_status(:created)
      expect(json_response.dig("data", "email")).to eq("newstudent@example.com")
      expect(json_response.dig("data", "roles")).to include("student")
    end

    it "returns validation errors for invalid params" do
      post "/api/v1/auth/register", params: { user: valid_params[:user].merge(email: "") }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response.dig("error", "code")).to eq("validation_error")
    end
  end
end
