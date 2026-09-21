module Quizzes
  class StartAttempt
    def initialize(enrollment:, quiz:)
      @enrollment = enrollment
      @quiz = quiz
    end

    def call
      return failure("Quiz is not published", "invalid_state") unless quiz.published?
      return failure("Quiz is not available", "invalid_state") unless quiz.available?
      return failure("Enrollment is not active", "invalid_state") unless enrollment.active?
      return failure("Course mismatch", "invalid_state") unless enrollment.course_id == quiz.course_id

      if quiz.quiz_attempts.for_enrollment(enrollment).in_progress.exists?
        return failure("An attempt is already in progress", "invalid_state")
      end

      unless quiz.unlimited_attempts?
        completed_count = quiz.quiz_attempts.for_enrollment(enrollment).where(status: %i[submitted expired]).count
        return failure("Maximum attempts reached", "invalid_state") if completed_count >= quiz.max_attempts
      end

      attempt = nil
      QuizAttempt.transaction do
        attempt_number = quiz.quiz_attempts.for_enrollment(enrollment).count + 1
        question_uuids = quiz.questions.ordered.pluck(:uuid)
        question_uuids.shuffle! if quiz.shuffle_questions?

        attempt = quiz.quiz_attempts.create!(
          enrollment: enrollment,
          attempt_number: attempt_number,
          status: :in_progress,
          started_at: Time.current,
          expires_at: quiz.time_limit_minutes.present? ? quiz.time_limit_minutes.minutes.from_now : nil,
          question_order: question_uuids,
          metadata: { shuffle_answers: quiz.shuffle_answers? }
        )
      end

      ServiceResult::Base.success(attempt)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult::Base.failure(
        errors: e.record.errors.map { |err| { field: err.attribute.to_s, message: err.full_message } },
        error_code: "validation_error"
      )
    end

    private

    attr_reader :enrollment, :quiz

    def failure(message, code)
      ServiceResult::Base.failure(errors: [ { field: "base", message: message } ], error_code: code)
    end
  end
end
