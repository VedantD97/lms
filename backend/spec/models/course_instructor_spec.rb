require "rails_helper"

RSpec.describe CourseInstructor, type: :model do
  subject { build(:course_instructor) }

  it { is_expected.to belong_to(:course) }
  it { is_expected.to belong_to(:user) }

  it "requires the user to be an instructor" do
    student = create(:user)
    course = create(:course)

    assignment = described_class.new(course: course, user: student, role: :lead)
    expect(assignment).not_to be_valid
    expect(assignment.errors[:user]).to include("must have instructor or admin role")
  end
end
