require "rails_helper"

RSpec.describe "Api::V1::Admin::Enrollments", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:student) { create(:user) }
  let(:course) { create(:course, :published) }

  before do
    course_module = create(:course_module, course: course, status: :published)
    create(:lesson, course_module: course_module, status: :published)
  end

  describe "POST /api/v1/admin/enrollments" do
    it "enrolls a student in a course" do
      post "/api/v1/admin/enrollments",
           params: { user_uuid: student.uuid, course_uuid: course.uuid },
           headers: auth_headers(admin)

      expect(response).to have_http_status(:created)
      expect(json_response.dig("data", "user_uuid")).to eq(student.uuid)
      expect(json_response.dig("data", "course_uuid")).to eq(course.uuid)
    end
  end
end
