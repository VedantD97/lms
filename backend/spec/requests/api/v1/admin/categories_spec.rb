require "rails_helper"

RSpec.describe "Api::V1::Admin::Categories", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "POST /api/v1/admin/categories" do
    it "creates a category" do
      post "/api/v1/admin/categories",
           params: { category: { name: "Design", description: "Design courses" } },
           headers: auth_headers(admin)

      expect(response).to have_http_status(:created)
      expect(json_response.dig("data", "slug")).to eq("design")
    end
  end
end
