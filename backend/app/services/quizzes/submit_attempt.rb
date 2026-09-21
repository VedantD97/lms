module Quizzes
  class SubmitAttempt
    def initialize(attempt:, responses: nil)
      @attempt = attempt
      @responses = responses
    end

    def call
      attempt.expire_if_needed!
      return failure("Attempt has expired", "invalid_state") if attempt.expired?
      return failure("Attempt already submitted", "invalid_state") if attempt.submitted?

      QuizAttempt.transaction do
        if responses.present?
          save_result = SaveResponses.new(attempt: attempt, responses: responses).call
          raise ActiveRecord::Rollback if save_result.failure?

          @attempt = save_result.data
        end

        return failure("Attempt is not editable", "invalid_state") unless attempt.in_progress?

        score_result = ScoreAttempt.new(attempt: attempt).call
        score_data = score_result.data

        attempt.update!(
          status: :submitted,
          submitted_at: Time.current,
          score: score_data[:score],
          max_score: score_data[:max_score],
          percentage: score_data[:percentage],
          passed: score_data[:passed],
          time_spent_seconds: [ (Time.current - attempt.started_at).to_i, 0 ].max
        )
      end

      return failure("Attempt is not editable", "invalid_state") unless attempt.submitted?

      Progress::RecalculateCourseProgress.new(enrollment: attempt.enrollment.reload).call

      ServiceResult::Base.success(attempt.reload)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult::Base.failure(
        errors: e.record.errors.map { |err| { field: err.attribute.to_s, message: err.full_message } },
        error_code: "validation_error"
      )
    end

    private

    attr_reader :attempt, :responses

    def failure(message, code)
      ServiceResult::Base.failure(errors: [ { field: "base", message: message } ], error_code: code)
    end
  end
end
