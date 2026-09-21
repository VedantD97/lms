require "rails_helper"

RSpec.describe Student::DashboardSummary do
  let(:student) { create(:user) }
  let(:course) { create(:course, :published) }

  before do
    create(:enrollment, user: student, course: course, progress_percent: 40)
    create(:notification, user: student, payload: { title: "Welcome", body: "Start learning" })
  end

  it "returns student-scoped dashboard stats" do
    summary = described_class.new(student: student).call

    expect(summary.dig(:enrollments, :total)).to eq(1)
    expect(summary.dig(:notifications, :unread_count)).to eq(1)
    expect(summary[:recent_notifications].length).to eq(1)
  end
end

RSpec.describe "Api::V1::Student::Dashboard", type: :request do
  let(:student) { create(:user) }
  let(:course) { create(:course, :published) }

  before do
    course_module = create(:course_module, course: course, status: :published)
    create(:lesson, course_module: course_module, status: :published)
    create(:enrollment, user: student, course: course)
  end

  describe "GET /api/v1/student/dashboard" do
    it "returns dashboard summary for student" do
      get "/api/v1/student/dashboard", headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "enrollments", "total")).to eq(1)
      expect(json_response.dig("data", "continue_learning")).to be_an(Array)
    end

    it "forbids non-student access" do
      instructor = create(:user, :instructor)
      get "/api/v1/student/dashboard", headers: auth_headers(instructor)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
