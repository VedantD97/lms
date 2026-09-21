require "rails_helper"

RSpec.describe "Api::V1::Notifications", type: :request do
  let(:student) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let!(:notification) { create(:notification, user: student) }

  describe "GET /api/v1/student/notifications" do
    it "returns notifications for the student" do
      get "/api/v1/student/notifications", headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", 0, "uuid")).to eq(notification.uuid)
    end
  end

  describe "GET /api/v1/student/notifications/unread_count" do
    it "returns unread count" do
      get "/api/v1/student/notifications/unread_count", headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "unread_count")).to eq(1)
    end
  end

  describe "PATCH /api/v1/student/notifications/:uuid/read" do
    it "marks a notification as read" do
      patch "/api/v1/student/notifications/#{notification.uuid}/read", headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "read")).to be(true)
    end
  end

  describe "POST /api/v1/admin/announcements" do
    it "creates a global announcement" do
      post "/api/v1/admin/announcements",
           params: { announcement: { title: "Maintenance", body: "Scheduled downtime Sunday." } },
           headers: auth_headers(admin)

      expect(response).to have_http_status(:created)
      expect(json_response.dig("data", "audience")).to eq("global")
    end
  end

  describe "POST /api/v1/admin/announcements/:uuid/publish" do
    let!(:announcement) { create(:announcement, author: admin) }

    it "publishes an announcement" do
      post "/api/v1/admin/announcements/#{announcement.uuid}/publish", headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "published")).to be(true)
    end
  end
end
