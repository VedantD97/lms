require "rails_helper"

RSpec.describe "Api::V1::Admin::Reports", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:student) { create(:user) }
  let(:course) { create(:course, :published) }

  before do
    create(:enrollment, user: student, course: course, status: :completed, progress_percent: 100)
  end

  describe "GET /api/v1/admin/reports/dashboard" do
    it "returns dashboard summary for admin" do
      get "/api/v1/admin/reports/dashboard", headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "users", "students")).to be >= 1
      expect(json_response.dig("data", "enrollments", "total")).to be >= 1
    end
  end

  describe "GET /api/v1/admin/reports/enrollments" do
    it "returns enrollment report data" do
      get "/api/v1/admin/reports/enrollments", headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "summary", "total")).to be >= 1
      expect(json_response.dig("data", "by_course")).to be_an(Array)
    end
  end

  describe "GET /api/v1/admin/reports/course_completion" do
    it "returns completion metrics by course" do
      get "/api/v1/admin/reports/course_completion", headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      row = json_response["data"].find { |item| item["course_uuid"] == course.uuid }
      expect(row["completed_enrollments"]).to eq(1)
    end
  end
end

RSpec.describe "Api::V1::Admin::AuditLogs", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:super_admin) { create(:user, :super_admin) }
  let!(:audit_log) { create(:audit_log, actor: super_admin) }

  describe "GET /api/v1/admin/audit_logs" do
    it "allows super admin to list audit logs" do
      get "/api/v1/admin/audit_logs", headers: auth_headers(super_admin)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", 0, "uuid")).to eq(audit_log.uuid)
    end

    it "forbids regular admin access" do
      get "/api/v1/admin/audit_logs", headers: auth_headers(admin)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
