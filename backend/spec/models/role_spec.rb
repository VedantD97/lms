require "rails_helper"

RSpec.describe Role, type: :model do
  subject { build(:role, :student) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to validate_inclusion_of(:name).in_array(Role::NAMES) }
end
