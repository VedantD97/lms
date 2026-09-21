require "rails_helper"

RSpec.describe Lesson, type: :model do
  it { is_expected.to belong_to(:course_module) }
  it { is_expected.to have_many(:lesson_resources).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:title) }
end
