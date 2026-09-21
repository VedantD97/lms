require "rails_helper"

RSpec.describe Quizzes::ScoreAttempt do
  let(:quiz) { create(:quiz, :published, passing_score: 50) }
  let!(:question) { create(:question, :single_choice, quiz: quiz, points: 10) }
  let(:enrollment) { create(:enrollment, course: quiz.course) }
  let(:attempt) { create(:quiz_attempt, quiz: quiz, enrollment: enrollment) }
  let(:correct_uuid) { question.correct_option_uuids.first }

  before do
    create(
      :quiz_response,
      quiz_attempt: attempt,
      question: question,
      selected_option_uuids: [ correct_uuid ]
    )
  end

  it "scores a correct response" do
    result = described_class.new(attempt: attempt).call

    expect(result).to be_success
    expect(result.data[:score]).to eq(10)
    expect(result.data[:percentage]).to eq(100)
    expect(result.data[:passed]).to be(true)
  end
end

RSpec.describe Quizzes::StartAttempt do
  let(:quiz) { create(:quiz, :published, max_attempts: 2) }
  let(:enrollment) { create(:enrollment, course: quiz.course) }

  it "creates an in-progress attempt" do
    result = described_class.new(enrollment: enrollment, quiz: quiz).call

    expect(result).to be_success
    expect(result.data).to be_in_progress
  end

  it "rejects when max attempts reached" do
    create(:quiz_attempt, quiz: quiz, enrollment: enrollment, status: :submitted, attempt_number: 1)
    create(:quiz_attempt, quiz: quiz, enrollment: enrollment, status: :submitted, attempt_number: 2)

    result = described_class.new(enrollment: enrollment, quiz: quiz).call

    expect(result).to be_failure
    expect(result.error_code).to eq("invalid_state")
  end
end

RSpec.describe Quizzes::SubmitAttempt do
  let(:quiz) { create(:quiz, :published, passing_score: 50) }
  let!(:question) { create(:question, :single_choice, quiz: quiz, points: 10) }
  let(:enrollment) { create(:enrollment, course: quiz.course) }
  let(:attempt) { create(:quiz_attempt, quiz: quiz, enrollment: enrollment) }
  let(:correct_uuid) { question.correct_option_uuids.first }

  it "submits and grades the attempt" do
    result = described_class.new(
      attempt: attempt,
      responses: [ { question_uuid: question.uuid, selected_option_uuids: [ correct_uuid ] } ]
    ).call

    expect(result).to be_success
    expect(result.data).to be_submitted
    expect(result.data.percentage).to eq(100)
    expect(result.data.passed).to be(true)
  end

  it "rejects duplicate submission" do
    described_class.new(
      attempt: attempt,
      responses: [ { question_uuid: question.uuid, selected_option_uuids: [ correct_uuid ] } ]
    ).call

    result = described_class.new(attempt: attempt.reload).call

    expect(result).to be_failure
  end
end
