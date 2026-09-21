require "rails_helper"

RSpec.describe "Api::V1::Assignments", type: :request do
  let(:instructor) { create(:user, :instructor) }
  let(:student) { create(:user) }
  let(:course) { create(:course, :published, created_by: instructor) }
  let!(:course_module) { create(:course_module, course: course, status: :published) }
  let!(:lesson) { create(:lesson, course_module: course_module, status: :published) }
  let!(:assignment) { create(:assignment, :published, course: course, lesson: lesson) }
  let!(:enrollment) { create(:enrollment, user: student, course: course) }

  before do
    enrollment.lesson_progresses.create!(lesson: lesson, status: :completed, progress_percent: 100)
  end

  describe "POST /api/v1/instructor/lessons/:lesson_uuid/assignments" do
    it "creates an assignment" do
      post "/api/v1/instructor/lessons/#{lesson.uuid}/assignments",
           params: { assignment: { title: "Essay 1", max_points: 50, passing_score: 60 } },
           headers: auth_headers(instructor)

      expect(response).to have_http_status(:created)
      expect(json_response.dig("data", "title")).to eq("Essay 1")
    end
  end

  describe "GET /api/v1/student/enrollments/:uuid/assignments" do
    it "lists assignments for enrolled student" do
      get "/api/v1/student/enrollments/#{enrollment.uuid}/assignments", headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", 0, "title")).to eq(assignment.title)
    end
  end

  describe "POST /api/v1/student/enrollments/:uuid/assignments/:assignment_uuid/submit" do
    it "submits assignment work" do
      post "/api/v1/student/enrollments/#{enrollment.uuid}/assignments/#{assignment.uuid}/submit",
           params: { submission: { body: "Here is my essay." } },
           headers: auth_headers(student)

      expect(response).to have_http_status(:created)
      expect(json_response.dig("data", "body")).to eq("Here is my essay.")
    end
  end

  describe "PATCH /api/v1/instructor/submissions/:uuid/grade" do
    let!(:submission) { create(:assignment_submission, assignment: assignment, enrollment: enrollment) }

    it "grades a submission" do
      patch "/api/v1/instructor/submissions/#{submission.uuid}/grade",
            params: { grade: { points: 88, feedback: "Well done" } },
            headers: auth_headers(instructor)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "grade", "passed")).to be(true)
      expect(enrollment.reload.progress_percent).to eq(100.0)
    end

    it "forbids grading by another instructor" do
      other = create(:user, :instructor)

      patch "/api/v1/instructor/submissions/#{submission.uuid}/grade",
            params: { grade: { points: 88 } },
            headers: auth_headers(other)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
