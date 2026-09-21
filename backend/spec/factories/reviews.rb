FactoryBot.define do
  factory :review do
    association :course, factory: %i[course published]
    user { create(:user) }
    rating { 5 }
    body { "Great course, learned a lot." }

    after(:build) do |review|
      next if review.user.enrollments.exists?(course: review.course)

      create(:enrollment, user: review.user, course: review.course)
    end
  end
end
