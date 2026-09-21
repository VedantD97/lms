FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    description { "Category description" }
    position { 0 }

    trait :with_parent do
      parent { association :category }
    end
  end

  factory :course do
    sequence(:title) { |n| "Course #{n}" }
    description { "Course description" }
    short_description { "Short description" }
    status { :draft }
    level { :beginner }
    duration_minutes { 120 }
    created_by { association :user, :instructor }

    trait :published do
      status { :published }
      published_at { Time.current }
    end

    trait :archived do
      status { :archived }
    end

    after(:create) do |course|
      instructor = course.created_by
      if instructor.instructor? && !course.course_instructors.exists?(user: instructor)
        course.course_instructors.create!(user: instructor, role: :lead)
      end
    end
  end

  factory :course_instructor do
    association :course
    user { association :user, :instructor }
    role { :lead }
  end

  factory :course_module, class: "CourseModule" do
    association :course
    sequence(:title) { |n| "Module #{n}" }
    description { "Module description" }
    position { 0 }
    status { :published }
  end

  factory :lesson do
    association :course_module
    sequence(:title) { |n| "Lesson #{n}" }
    content { "Lesson content" }
    content_type { :text }
    position { 0 }
    status { :published }
    is_preview { false }
  end

  factory :lesson_resource do
    association :lesson
    resource_type { :link }
    sequence(:title) { |n| "Resource #{n}" }
    external_url { "https://example.com/resource" }
    position { 0 }
    metadata { {} }
  end

  factory :enrollment do
    user
    course { association :course, :published }
    status { :active }
    enrolled_at { Time.current }
    progress_percent { 0 }
  end

  factory :lesson_progress do
    enrollment
    status { :not_started }
    progress_percent { 0 }
    last_position_seconds { 0 }

    after(:build) do |progress|
      next if progress.lesson.present?

      course_module = create(:course_module, course: progress.enrollment.course, status: :published)
      progress.lesson = create(:lesson, course_module: course_module, status: :published)
    end
  end
end
