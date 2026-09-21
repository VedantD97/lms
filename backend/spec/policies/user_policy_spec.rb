require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  subject { described_class }

  let(:student) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:other_user) { create(:user) }

  permissions :show? do
    it "allows users to view their own profile" do
      expect(subject).to permit(student, student)
    end

    it "allows admins to view any profile" do
      expect(subject).to permit(admin, other_user)
    end

    it "denies users from viewing other profiles" do
      expect(subject).not_to permit(student, other_user)
    end
  end
end
