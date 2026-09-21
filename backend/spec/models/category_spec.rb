require "rails_helper"

RSpec.describe Category, type: :model do
  it { is_expected.to validate_presence_of(:name) }

  it "generates a slug from the name" do
    category = create(:category, name: "Web Development")
    expect(category.slug).to eq("web-development")
  end

  it "enforces unique slugs" do
    create(:category, name: "Ruby", slug: "ruby")
    duplicate = build(:category, name: "Ruby 2", slug: "ruby")

    expect(duplicate).not_to be_valid
  end
end
