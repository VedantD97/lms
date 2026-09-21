require "rails_helper"

RSpec.describe "Api::V1::Student::Courses", type: :request do
  let(:student) { create(:user) }

  describe "GET /api/v1/student/courses" do
    it "lists published courses" do
      published = create(:course, :published, title: "Published Course")
      create(:course, title: "Draft Course", status: :draft)

      get "/api/v1/student/courses", headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      titles = json_response.fetch("data").map { |course| course["title"] }
      expect(titles).to include("Published Course")
      expect(titles).not_to include("Draft Course")
    end
  end

  describe "POST /api/v1/student/courses/:uuid/enroll" do
    it "enrolls the current student" do
      course = create(:course, :published)
      course_module = create(:course_module, course: course, status: :published)
      create(:lesson, course_module: course_module, status: :published)

      post "/api/v1/student/courses/#{course.uuid}/enroll", headers: auth_headers(student)

      expect(response).to have_http_status(:created)
      expect(json_response.dig("data", "course_uuid")).to eq(course.uuid)
    end
  end
end
