require "rails_helper"

RSpec.describe Course, type: :model do
  subject { build(:course) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to belong_to(:created_by).class_name("User") }
  it { is_expected.to have_many(:course_modules).dependent(:destroy) }
  it { is_expected.to have_many(:enrollments).dependent(:destroy) }

  describe "#published_lessons" do
    it "returns only published lessons from published modules" do
      course = create(:course, :published)
      published_module = create(:course_module, course: course, status: :published)
      draft_module = create(:course_module, course: course, status: :draft, title: "Draft Module")
      published_lesson = create(:lesson, course_module: published_module, status: :published)
      create(:lesson, course_module: published_module, status: :draft, title: "Draft Lesson")
      create(:lesson, course_module: draft_module, status: :published, title: "Hidden Lesson")

      expect(course.published_lessons).to contain_exactly(published_lesson)
    end
  end
end
