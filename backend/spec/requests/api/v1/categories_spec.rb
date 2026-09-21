require "rails_helper"

RSpec.describe "Api::V1::Categories", type: :request do
  describe "GET /api/v1/categories" do
    it "lists root categories" do
      category = create(:category, name: "Programming")

      get "/api/v1/categories"

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", 0, "name")).to eq("Programming")
      expect(json_response.dig("meta", "total")).to eq(1)
    end
  end
end
