require "rails_helper"

RSpec.describe CourseModule, type: :model do
  it { is_expected.to belong_to(:course) }
  it { is_expected.to have_many(:lessons).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:title) }
end
