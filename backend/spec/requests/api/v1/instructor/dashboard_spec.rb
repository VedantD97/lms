require "rails_helper"

RSpec.describe Instructor::DashboardSummary do
  let(:instructor) { create(:user, :instructor) }
  let(:course) { create(:course, :published, created_by: instructor) }
  let(:student) { create(:user) }

  before do
    create(:enrollment, user: student, course: course)
  end

  it "returns stats scoped to instructor courses" do
    summary = described_class.new(instructor: instructor).call

    expect(summary.dig(:courses, :total)).to eq(1)
    expect(summary.dig(:enrollments, :total)).to eq(1)
    expect(summary.dig(:course_breakdown, 0, :course_uuid)).to eq(course.uuid)
  end
end

RSpec.describe "Api::V1::Instructor::Dashboard", type: :request do
  let(:instructor) { create(:user, :instructor) }
  let(:course) { create(:course, :published, created_by: instructor) }
  let(:student) { create(:user) }

  before do
    create(:enrollment, user: student, course: course)
  end

  describe "GET /api/v1/instructor/dashboard" do
    it "returns instructor dashboard summary" do
      get "/api/v1/instructor/dashboard", headers: auth_headers(instructor)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "courses", "total")).to eq(1)
      expect(json_response.dig("data", "enrollments", "total")).to eq(1)
    end
  end
end

RSpec.describe "Api::V1::Instructor::Enrollments", type: :request do
  let(:instructor) { create(:user, :instructor) }
  let(:other_instructor) { create(:user, :instructor) }
  let(:course) { create(:course, :published, created_by: instructor) }
  let(:student) { create(:user) }
  let!(:enrollment) { create(:enrollment, user: student, course: course) }

  describe "GET /api/v1/instructor/courses/:uuid/enrollments" do
    it "lists enrollments for instructor course" do
      get "/api/v1/instructor/courses/#{course.uuid}/enrollments", headers: auth_headers(instructor)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", 0, "uuid")).to eq(enrollment.uuid)
      expect(json_response.dig("data", 0, "student", "email")).to eq(student.email)
    end

    it "forbids other instructors" do
      get "/api/v1/instructor/courses/#{course.uuid}/enrollments", headers: auth_headers(other_instructor)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/instructor/enrollments/:uuid/progress" do
    it "returns enrollment progress detail" do
      get "/api/v1/instructor/enrollments/#{enrollment.uuid}/progress", headers: auth_headers(instructor)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "progress_summary")).to be_present
    end
  end
end

RSpec.describe "Api::V1::Instructor::Submissions pending", type: :request do
  let(:instructor) { create(:user, :instructor) }
  let(:course) { create(:course, :published, created_by: instructor) }
  let(:student) { create(:user) }
  let(:assignment) { create(:assignment, :published, course: course) }
  let(:enrollment) { create(:enrollment, user: student, course: course) }
  let!(:submission) { create(:assignment_submission, assignment: assignment, enrollment: enrollment) }

  describe "GET /api/v1/instructor/submissions/pending" do
    it "lists ungraded submissions" do
      get "/api/v1/instructor/submissions/pending", headers: auth_headers(instructor)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", 0, "uuid")).to eq(submission.uuid)
      expect(json_response.dig("data", 0, "assignment_title")).to eq(assignment.title)
    end
  end
end
