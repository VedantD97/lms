require "rails_helper"

RSpec.describe LessonProgress, type: :model do
  it { is_expected.to belong_to(:enrollment) }
  it { is_expected.to belong_to(:lesson) }

  it "prevents duplicate progress rows" do
    progress = create(:lesson_progress)
    duplicate = build(:lesson_progress, enrollment: progress.enrollment, lesson: progress.lesson)

    expect(duplicate).not_to be_valid
  end

  it "requires the lesson to belong to the enrolled course" do
    enrollment = create(:enrollment)
    other_lesson = create(:lesson)

    progress = described_class.new(
      enrollment: enrollment,
      lesson: other_lesson,
      status: :not_started
    )

    expect(progress).not_to be_valid
    expect(progress.errors[:lesson]).to include("must belong to the enrolled course")
  end
end
