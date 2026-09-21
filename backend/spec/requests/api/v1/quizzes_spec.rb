require "rails_helper"

RSpec.describe "Api::V1::Instructor::Quizzes", type: :request do
  let(:instructor) { create(:user, :instructor) }
  let(:course) { create(:course, created_by: instructor) }
  let(:course_module) { create(:course_module, course: course) }
  let(:lesson) { create(:lesson, course_module: course_module) }

  describe "POST /api/v1/instructor/lessons/:lesson_uuid/quizzes" do
    it "creates a quiz for a lesson" do
      post "/api/v1/instructor/lessons/#{lesson.uuid}/quizzes",
           params: { quiz: { title: "Midterm", passing_score: 75, max_attempts: 2 } },
           headers: auth_headers(instructor)

      expect(response).to have_http_status(:created)
      expect(json_response.dig("data", "title")).to eq("Midterm")
      expect(json_response.dig("data", "lesson_uuid")).to eq(lesson.uuid)
    end
  end

  describe "GET /api/v1/instructor/quizzes/:uuid" do
    let(:quiz) { create(:quiz, course: course, lesson: lesson) }
    let!(:question) { create(:question, :single_choice, quiz: quiz) }

    it "returns quiz with correct answers for instructor" do
      get "/api/v1/instructor/quizzes/#{quiz.uuid}", headers: auth_headers(instructor)

      expect(response).to have_http_status(:ok)
      options = json_response.dig("data", "questions", 0, "question_options")
      expect(options.first).to have_key("is_correct")
    end
  end
end

RSpec.describe "Api::V1::Student::Quizzes", type: :request do
  let(:student) { create(:user) }
  let(:course) { create(:course, :published) }
  let!(:enrollment) { create(:enrollment, user: student, course: course) }
  let(:quiz) { create(:quiz, :published, course: course, max_attempts: 2) }
  let!(:question) { create(:question, :single_choice, quiz: quiz, points: 10) }

  describe "quiz attempt flow" do
    it "starts, saves, submits, and returns results without leaking correct answers before submit" do
      post "/api/v1/student/enrollments/#{enrollment.uuid}/quizzes/#{quiz.uuid}/start",
           headers: auth_headers(student)
      expect(response).to have_http_status(:created)

      attempt_uuid = json_response.dig("data", "uuid")
      options = json_response.dig("data", "questions", 0, "question_options")
      expect(options.first).not_to have_key("is_correct")

      correct_uuid = question.reload.correct_option_uuids.first

      patch "/api/v1/student/quiz_attempts/#{attempt_uuid}/responses",
            params: {
              responses: [ { question_uuid: question.uuid, selected_option_uuids: [ correct_uuid ] } ]
            },
            headers: auth_headers(student)
      expect(response).to have_http_status(:ok)

      post "/api/v1/student/quiz_attempts/#{attempt_uuid}/submit",
           headers: auth_headers(student)
      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "passed")).to be(true)
      expect(json_response.dig("data", "percentage").to_f).to eq(100.0)
    end

    it "forbids access to another student's attempt" do
      attempt = create(:quiz_attempt, quiz: quiz, enrollment: enrollment)
      other_student = create(:user)

      get "/api/v1/student/quiz_attempts/#{attempt.uuid}", headers: auth_headers(other_student)
      expect(response).to have_http_status(:forbidden)
    end
  end
end

RSpec.describe "Api::V1::Admin::Quizzes", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:quiz) { create(:quiz, :published) }

  it "returns quiz statistics" do
    enrollment = create(:enrollment, course: quiz.course)
    create(
      :quiz_attempt,
      quiz: quiz,
      enrollment: enrollment,
      status: :submitted,
      score: 8,
      max_score: 10,
      percentage: 80,
      passed: true,
      submitted_at: Time.current
    )

    get "/api/v1/admin/quizzes/#{quiz.uuid}/statistics", headers: auth_headers(admin)

    expect(response).to have_http_status(:ok)
    expect(json_response.dig("data", "completed_attempts")).to eq(1)
    expect(json_response.dig("data", "pass_rate")).to eq(100)
  end
end
