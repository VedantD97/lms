require "rails_helper"

RSpec.describe Review do
  it "requires rating between 1 and 5" do
    review = build(:review, rating: 6)

    expect(review).not_to be_valid
  end

  it "prevents duplicate reviews per user and course" do
    existing = create(:review)
    duplicate = build(:review, user: existing.user, course: existing.course)

    expect(duplicate).not_to be_valid
  end

  it "requires enrollment" do
    user = create(:user)
    course = create(:course, :published)
    review = Review.new(user: user, course: course, rating: 5, body: "Nice course")

    expect(review).not_to be_valid
    expect(review.errors[:user]).to include("must be enrolled in the course to review it")
  end
end

RSpec.describe Course do
  it "calculates average rating" do
    course = create(:course, :published)
    create(:review, course: course, rating: 4)
    create(:review, course: course, rating: 5)

    expect(course.average_rating).to eq(4.5)
    expect(course.review_count).to eq(2)
  end
end
