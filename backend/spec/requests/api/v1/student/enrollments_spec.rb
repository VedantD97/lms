require "rails_helper"

RSpec.describe "Api::V1::Student::Enrollments", type: :request do
  let(:student) { create(:user) }
  let(:course) { create(:course, :published) }
  let!(:course_module) { create(:course_module, course: course, status: :published) }
  let!(:lesson) { create(:lesson, course_module: course_module, status: :published) }
  let!(:enrollment) { create(:enrollment, user: student, course: course) }

  before do
    enrollment.lesson_progresses.create!(lesson: lesson, status: :not_started)
  end

  describe "GET /api/v1/student/enrollments/:uuid" do
    it "returns enrollment with lesson progress" do
      get "/api/v1/student/enrollments/#{enrollment.uuid}", headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "uuid")).to eq(enrollment.uuid)
      expect(json_response.dig("data", "lesson_progress")).not_to be_empty
    end
  end

  describe "POST /api/v1/student/enrollments/:uuid/lessons/:lesson_uuid/complete" do
    it "marks a lesson complete and updates course progress" do
      post "/api/v1/student/enrollments/#{enrollment.uuid}/lessons/#{lesson.uuid}/complete",
           headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "status")).to eq("completed")

      enrollment.reload
      expect(enrollment.progress_percent).to eq(100.0)
      expect(enrollment).to be_completed
    end
  end

  describe "PATCH /api/v1/student/enrollments/:uuid/lessons/:lesson_uuid/progress" do
    it "updates lesson watch progress" do
      patch "/api/v1/student/enrollments/#{enrollment.uuid}/lessons/#{lesson.uuid}/progress",
            params: { progress: { progress_percent: 50, last_position_seconds: 120 } },
            headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "progress_percent")).to eq("50.0")
      expect(json_response.dig("data", "status")).to eq("in_progress")
    end
  end
end
