require "rails_helper"

RSpec.describe Assignments::SubmitSubmission do
  let(:assignment) { create(:assignment, :published) }
  let(:enrollment) { create(:enrollment, course: assignment.course) }

  it "creates a submission" do
    result = described_class.new(enrollment: enrollment, assignment: assignment, body: "My answer").call

    expect(result).to be_success
    expect(result.data).to be_submitted
    expect(result.data.body).to eq("My answer")
  end

  it "rejects blank body" do
    result = described_class.new(enrollment: enrollment, assignment: assignment, body: "  ").call

    expect(result).to be_failure
    expect(result.error_code).to eq("validation_error")
  end

  it "rejects late submission when not allowed" do
    assignment.update!(due_at: 1.day.ago, allow_late: false)

    result = described_class.new(enrollment: enrollment, assignment: assignment, body: "Late work").call

    expect(result).to be_failure
    expect(result.error_code).to eq("invalid_state")
  end

  it "allows resubmit after failed grade" do
    submission = create(:assignment_submission, assignment: assignment, enrollment: enrollment, status: :graded)
    create(:grade, gradable: submission, points: 40, percentage: 40, passed: false)

    result = described_class.new(enrollment: enrollment, assignment: assignment, body: "Retry").call

    expect(result).to be_success
    expect(result.data.body).to eq("Retry")
    expect(result.data.grade).to be_nil
  end
end

RSpec.describe Assignments::GradeSubmission do
  let(:assignment) { create(:assignment, :published, max_points: 100, passing_score: 70) }
  let(:enrollment) { create(:enrollment, course: assignment.course) }
  let(:submission) { create(:assignment_submission, assignment: assignment, enrollment: enrollment) }
  let(:grader) { assignment.course.created_by }

  it "grades a submission and recalculates progress" do
    result = described_class.new(submission: submission, grader: grader, points: 85, feedback: "Nice").call

    expect(result).to be_success
    expect(result.data).to be_graded
    expect(result.data.grade.passed).to be(true)
    expect(result.data.grade.feedback).to eq("Nice")
  end

  it "marks submission as failed below passing score" do
    result = described_class.new(submission: submission, grader: grader, points: 50).call

    expect(result.data.grade.passed).to be(false)
  end
end

RSpec.describe Progress::CourseCompletion do
  let(:course) { create(:course, :published) }
  let(:course_module) { create(:course_module, course: course, status: :published) }
  let!(:lesson) { create(:lesson, course_module: course_module, status: :published) }
  let!(:assignment) { create(:assignment, :published, course: course) }
  let(:enrollment) { create(:enrollment, course: course) }

  before do
    enrollment.lesson_progresses.create!(lesson: lesson, status: :completed, progress_percent: 100)
  end

  it "includes assignments in progress summary" do
    summary = described_class.new(enrollment: enrollment).summary

    expect(summary[:total_items]).to eq(2)
    expect(summary[:total_assignments]).to eq(1)
    expect(summary[:passed_assignments]).to eq(0)
  end

  it "counts passed graded assignments" do
    submission = create(:assignment_submission, assignment: assignment, enrollment: enrollment, status: :graded)
    create(:grade, gradable: submission, points: 90, percentage: 90, passed: true)

    completion = described_class.new(enrollment: enrollment)

    expect(completion.complete?).to be(true)
    expect(completion.progress_percent).to eq(100.0)
  end
end
