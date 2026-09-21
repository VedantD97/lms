require "rails_helper"

RSpec.describe Enrollment, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:course) }

  it "prevents duplicate enrollments for the same user and course" do
    enrollment = create(:enrollment)
    duplicate = build(:enrollment, user: enrollment.user, course: enrollment.course)

    expect(duplicate).not_to be_valid
  end

  it "requires a published course" do
    student = create(:user)
    course = create(:course, status: :draft)

    enrollment = described_class.new(user: student, course: course, enrolled_at: Time.current)
    expect(enrollment).not_to be_valid
    expect(enrollment.errors[:course]).to include("must be published")
  end
end
