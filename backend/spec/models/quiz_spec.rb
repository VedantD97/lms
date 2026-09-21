require "rails_helper"

RSpec.describe Quiz, type: :model do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_numericality_of(:passing_score).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
end

RSpec.describe Question, type: :model do
  it { is_expected.to validate_presence_of(:body) }

  it "creates true/false options automatically" do
    question = create(:question, :true_false)
    expect(question.question_options.count).to eq(2)
  end
end

RSpec.describe QuizAttempt, type: :model do
  it "expires in-progress attempts past the time limit" do
    attempt = create(:quiz_attempt, expires_at: 1.minute.ago)
    attempt.expire_if_needed!
    expect(attempt).to be_expired
  end
end
