require "rails_helper"

RSpec.describe "Critical user journey smoke test", type: :request do
  let(:student) { create(:user) }
  let(:course) { create(:course, :published, title: "Smoke Test Course") }
  let!(:course_module) { create(:course_module, course: course, status: :published) }
  let!(:lesson) do
    create(
      :lesson,
      course_module: course_module,
      status: :published,
      title: "Intro",
      content: "Welcome to the course",
      content_type: :text
    )
  end

  it "covers enroll → learn → complete → dashboard" do
    post "/api/v1/student/courses/#{course.uuid}/enroll", headers: auth_headers(student)
    expect(response).to have_http_status(:created)

    enrollment_uuid = json_response.dig("data", "uuid")

    get "/api/v1/student/enrollments/#{enrollment_uuid}/lessons/#{lesson.uuid}",
        headers: auth_headers(student)
    expect(response).to have_http_status(:ok)
    expect(json_response.dig("data", "content")).to eq("Welcome to the course")

    patch "/api/v1/student/enrollments/#{enrollment_uuid}/lessons/#{lesson.uuid}/progress",
          params: { progress: { progress_percent: 80, last_position_seconds: 120 } },
          headers: auth_headers(student)
    expect(response).to have_http_status(:ok)
    expect(json_response.dig("data", "progress_percent").to_f).to eq(80.0)

    post "/api/v1/student/enrollments/#{enrollment_uuid}/lessons/#{lesson.uuid}/complete",
         headers: auth_headers(student)
    expect(response).to have_http_status(:ok)
    expect(json_response.dig("data", "status")).to eq("completed")

    get "/api/v1/student/dashboard", headers: auth_headers(student)
    expect(response).to have_http_status(:ok)
    expect(json_response.dig("data", "continue_learning")).to be_an(Array)
    expect(json_response.dig("data", "enrollments", "total")).to eq(1)
    expect(json_response.dig("data", "enrollments", "completed")).to eq(1)
  end

  it "blocks another student from the enrollment journey" do
    post "/api/v1/student/courses/#{course.uuid}/enroll", headers: auth_headers(student)
    enrollment_uuid = json_response.dig("data", "uuid")
    other_student = create(:user)

    get "/api/v1/student/enrollments/#{enrollment_uuid}/lessons/#{lesson.uuid}",
        headers: auth_headers(other_student)
    expect(response).to have_http_status(:forbidden)
  end
end
