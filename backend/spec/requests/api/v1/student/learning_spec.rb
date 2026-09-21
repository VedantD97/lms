require "rails_helper"

RSpec.describe "Api::V1::Student::Learning", type: :request do
  let(:student) { create(:user) }
  let(:other_student) { create(:user) }
  let(:course) { create(:course, :published) }
  let!(:course_module) { create(:course_module, course: course, status: :published) }
  let!(:lesson) { create(:lesson, course_module: course_module, status: :published, content: "Hello world", content_type: :text) }
  let!(:enrollment) { create(:enrollment, user: student, course: course) }

  before do
    enrollment.lesson_progresses.create!(lesson: lesson, status: :not_started)
  end

  describe "GET /api/v1/student/enrollments" do
    it "returns enrollments with course info and continue learning" do
      get "/api/v1/student/enrollments", headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", 0, "course", "title")).to eq(course.title)
      expect(json_response.dig("data", 0, "continue_learning", "lesson_uuid")).to eq(lesson.uuid)
      expect(json_response.dig("data", 0, "progress_summary", "total_items")).to eq(1)
    end
  end

  describe "GET /api/v1/student/enrollments with quizzes" do
    let!(:quiz) { create(:quiz, :published, course: course) }

    it "includes quiz in progress summary" do
      get "/api/v1/student/enrollments", headers: auth_headers(student)

      summary = json_response.dig("data", 0, "progress_summary")
      expect(summary["total_items"]).to eq(2)
      expect(summary["total_quizzes"]).to eq(1)
      expect(summary["passed_quizzes"]).to eq(0)
    end
  end

  describe "GET /api/v1/student/enrollments/:uuid/lessons/:lesson_uuid" do
    it "returns lesson content without unsigned blob paths" do
      get "/api/v1/student/enrollments/#{enrollment.uuid}/lessons/#{lesson.uuid}",
          headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "content")).to eq("Hello world")
      expect(json_response.dig("data", "progress", "status")).to eq("not_started")
    end

    it "forbids access for another student" do
      get "/api/v1/student/enrollments/#{enrollment.uuid}/lessons/#{lesson.uuid}",
          headers: auth_headers(other_student)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/student/enrollments/:uuid/resources/:resource_uuid/download" do
    let!(:resource) { create(:lesson_resource, lesson: lesson, resource_type: :link, external_url: "https://example.com/doc.pdf") }

    it "returns external url for link resources" do
      get "/api/v1/student/enrollments/#{enrollment.uuid}/resources/#{resource.uuid}/download",
          headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "external_url")).to eq("https://example.com/doc.pdf")
    end

    it "forbids download for another student" do
      get "/api/v1/student/enrollments/#{enrollment.uuid}/resources/#{resource.uuid}/download",
          headers: auth_headers(other_student)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
