FactoryBot.define do
  factory :assignment do
    association :course, factory: %i[course published]
    sequence(:title) { |n| "Assignment #{n}" }
    description { "Assignment instructions" }
    max_points { 100 }
    passing_score { 70 }
    allow_late { false }
    allow_resubmit { true }
    required_for_completion { true }
    status { :draft }

    trait :published do
      status { :published }
    end

    trait :with_lesson do
      after(:build) do |assignment|
        course_module = create(:course_module, course: assignment.course, status: :published)
        assignment.lesson = create(:lesson, course_module: course_module, status: :published)
      end
    end

    trait :past_due do
      due_at { 1.day.ago }
    end
  end

  factory :assignment_submission do
    association :assignment, factory: %i[assignment published]
    enrollment
    body { "My submission text" }
    submitted_at { Time.current }
    status { :submitted }

    after(:build) do |submission|
      submission.enrollment ||= create(:enrollment, course: submission.assignment.course)
    end

    trait :graded do
      status { :graded }

      after(:create) do |submission|
        create(:grade, gradable: submission, points: 85, percentage: 85, passed: true)
      end
    end
  end

  factory :grade do
    association :gradable, factory: :assignment_submission
    association :graded_by, factory: %i[user instructor]
    points { 85 }
    percentage { 85 }
    passed { true }
    feedback { "Good work" }
    graded_at { Time.current }
  end
end
