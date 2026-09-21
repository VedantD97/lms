require "rails_helper"

RSpec.describe Progress::CourseCompletion do
  let(:course) { create(:course, :published) }
  let(:course_module) { create(:course_module, course: course, status: :published) }
  let!(:lesson) { create(:lesson, course_module: course_module, status: :published) }
  let!(:quiz) { create(:quiz, :published, course: course) }
  let(:enrollment) { create(:enrollment, course: course) }

  before do
    enrollment.lesson_progresses.create!(lesson: lesson, status: :completed, progress_percent: 100)
  end

  it "counts lessons and quizzes as required items" do
    summary = described_class.new(enrollment: enrollment).summary

    expect(summary[:total_items]).to eq(2)
    expect(summary[:completed_items]).to eq(1)
    expect(summary[:completed_lessons]).to eq(1)
    expect(summary[:passed_quizzes]).to eq(0)
  end

  it "marks complete when all required items are done" do
    create(:quiz_attempt, quiz: quiz, enrollment: enrollment, status: :submitted, passed: true, submitted_at: Time.current)

    completion = described_class.new(enrollment: enrollment)

    expect(completion.complete?).to be(true)
    expect(completion.progress_percent).to eq(100.0)
  end

  it "excludes preview lessons and optional quizzes" do
    preview_module = create(:course_module, course: course, status: :published, position: 1)
    create(:lesson, course_module: preview_module, status: :published, is_preview: true)
    create(:quiz, :published, course: course, required_for_completion: false)

    summary = described_class.new(enrollment: enrollment.reload).summary

    expect(summary[:total_items]).to eq(2)
  end
end

RSpec.describe Progress::ContinueLearning do
  let(:course) { create(:course, :published) }
  let(:course_module) { create(:course_module, course: course, status: :published, position: 0) }
  let!(:lesson_one) { create(:lesson, course_module: course_module, title: "Lesson 1", position: 0, status: :published) }
  let!(:lesson_two) { create(:lesson, course_module: course_module, title: "Lesson 2", position: 1, status: :published) }
  let(:enrollment) { create(:enrollment, course: course) }

  before do
    enrollment.lesson_progresses.create!(lesson: lesson_one, status: :completed, progress_percent: 100)
    enrollment.lesson_progresses.create!(lesson: lesson_two, status: :in_progress, progress_percent: 25, last_position_seconds: 90)
  end

  it "returns the next incomplete lesson" do
    result = described_class.new(enrollment: enrollment).call

    expect(result.data[:lesson_uuid]).to eq(lesson_two.uuid)
    expect(result.data[:last_position_seconds]).to eq(90)
  end

  it "returns nil when all lessons are completed" do
    enrollment.lesson_progresses.find_by(lesson: lesson_two).update!(status: :completed, progress_percent: 100)

    result = described_class.new(enrollment: enrollment).call

    expect(result.data).to be_nil
  end
end

RSpec.describe Progress::RecalculateCourseProgress do
  let(:course) { create(:course, :published) }
  let(:course_module) { create(:course_module, course: course, status: :published) }
  let!(:lesson) { create(:lesson, course_module: course_module, status: :published) }
  let!(:quiz) { create(:quiz, :published, course: course, passing_score: 50) }
  let!(:question) { create(:question, :single_choice, quiz: quiz, points: 10) }
  let(:enrollment) { create(:enrollment, course: course) }

  before do
    enrollment.lesson_progresses.create!(lesson: lesson, status: :completed, progress_percent: 100)
  end

  it "does not complete enrollment until required quizzes are passed" do
    described_class.new(enrollment: enrollment).call

    enrollment.reload
    expect(enrollment.progress_percent).to eq(50.0)
    expect(enrollment).to be_active
  end

  it "sets enrollment progress to 100 when all required items are complete" do
    create(
      :quiz_attempt,
      quiz: quiz,
      enrollment: enrollment,
      status: :submitted,
      passed: true,
      submitted_at: Time.current,
      percentage: 100
    )

    described_class.new(enrollment: enrollment).call

    enrollment.reload
    expect(enrollment.progress_percent).to eq(100)
    expect(enrollment).to be_completed
  end

  it "recalculates after quiz submission" do
    attempt = create(:quiz_attempt, quiz: quiz, enrollment: enrollment)
    correct_uuid = question.correct_option_uuids.first

    Quizzes::SubmitAttempt.new(
      attempt: attempt,
      responses: [ { question_uuid: question.uuid, selected_option_uuids: [ correct_uuid ] } ]
    ).call

    enrollment.reload
    expect(enrollment.progress_percent).to eq(100)
    expect(enrollment).to be_completed
  end
end
