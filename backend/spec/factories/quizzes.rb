FactoryBot.define do
  factory :quiz do
    association :course, factory: %i[course published]
    sequence(:title) { |n| "Quiz #{n}" }
    description { "Quiz description" }
    passing_score { 70 }
    max_attempts { 3 }
    shuffle_questions { false }
    shuffle_answers { false }
    status { :draft }
    show_correct_answers { :after_submit }

    trait :published do
      status { :published }
    end

    trait :with_lesson do
      after(:build) do |quiz|
        course_module = create(:course_module, course: quiz.course, status: :published)
        quiz.lesson = create(:lesson, course_module: course_module, status: :published)
      end
    end
  end

  factory :question do
    association :quiz
    question_type { :single_choice }
    sequence(:body) { |n| "Question #{n}?" }
    points { 1 }
    position { 0 }

    trait :multiple_choice do
      question_type { :multiple_choice }
      after(:create) do |question|
        create(:question_option, question: question, body: "A", is_correct: true, position: 0)
        create(:question_option, question: question, body: "B", is_correct: true, position: 1)
        create(:question_option, question: question, body: "C", is_correct: false, position: 2)
      end
    end

    trait :single_choice do
      after(:create) do |question|
        create(:question_option, question: question, body: "Correct", is_correct: true, position: 0)
        create(:question_option, question: question, body: "Wrong", is_correct: false, position: 1)
      end
    end

    trait :true_false do
      question_type { :true_false }
    end
  end

  factory :question_option do
    association :question
    sequence(:body) { |n| "Option #{n}" }
    is_correct { false }
    position { 0 }
  end

  factory :quiz_attempt do
    association :quiz, factory: %i[quiz published]
    enrollment
    attempt_number { 1 }
    status { :in_progress }
    started_at { Time.current }
    question_order { [] }

    after(:build) do |attempt|
      attempt.enrollment ||= create(:enrollment, course: attempt.quiz.course)
      attempt.question_order = attempt.quiz.questions.ordered.pluck(:uuid)
    end
  end

  factory :quiz_response do
    association :quiz_attempt
    association :question
    selected_option_uuids { [] }

    after(:build) do |response|
      next if response.question.present?

      response.question = create(:question, :single_choice, quiz: response.quiz_attempt.quiz)
    end
  end
end
