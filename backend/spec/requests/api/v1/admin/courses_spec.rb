require "rails_helper"

RSpec.describe "Api::V1::Admin::Courses", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "POST /api/v1/admin/courses" do
    it "creates a course" do
      post "/api/v1/admin/courses",
           params: { course: { title: "Ruby Basics", description: "Learn Ruby" } },
           headers: auth_headers(admin)

      expect(response).to have_http_status(:created)
      expect(json_response.dig("data", "title")).to eq("Ruby Basics")
    end
  end

  describe "POST /api/v1/admin/courses/:uuid/instructors" do
    it "assigns an instructor to a course" do
      course = create(:course)
      instructor = create(:user, :instructor)

      post "/api/v1/admin/courses/#{course.uuid}/instructors",
           params: { user_uuid: instructor.uuid, role: "lead" },
           headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "instructor_uuids")).to include(instructor.uuid)
    end
  end
end
