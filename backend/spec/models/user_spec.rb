require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }

  describe "#assign_role!" do
    it "assigns a role to the user" do
      user = create(:user)
      user.roles.destroy_all
      user.assign_role!("instructor")

      expect(user.role_names).to include("instructor")
    end
  end

  describe "#highest_role" do
    it "returns the highest privilege role" do
      user = create(:user)
      user.roles.destroy_all
      user.assign_role!("student")
      user.assign_role!("instructor")

      expect(user.highest_role).to eq("instructor")
    end
  end
end
