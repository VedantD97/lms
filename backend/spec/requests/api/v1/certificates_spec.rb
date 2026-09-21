require "rails_helper"

RSpec.describe "Api::V1::Certificates", type: :request do
  let(:student) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:course) { create(:course, :published) }
  let(:enrollment) { create(:enrollment, user: student, course: course, status: :completed, progress_percent: 100, completed_at: Time.current) }
  let!(:certificate) { create(:certificate, enrollment: enrollment) }

  describe "GET /api/v1/student/certificates" do
    it "returns active certificates for the student" do
      get "/api/v1/student/certificates", headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", 0, "certificate_number")).to eq(certificate.certificate_number)
    end

    it "excludes revoked certificates" do
      certificate.update!(revoked_at: Time.current)

      get "/api/v1/student/certificates", headers: auth_headers(student)

      expect(json_response["data"]).to be_empty
    end
  end

  describe "GET /api/v1/admin/certificates" do
    it "lists certificates for admin" do
      get "/api/v1/admin/certificates", headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", 0, "uuid")).to eq(certificate.uuid)
    end
  end

  describe "POST /api/v1/admin/certificates/:uuid/revoke" do
    it "revokes a certificate" do
      post "/api/v1/admin/certificates/#{certificate.uuid}/revoke", headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "revoked")).to be(true)
      expect(certificate.reload).to be_revoked
    end
  end
end
