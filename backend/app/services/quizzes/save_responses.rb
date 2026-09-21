module Quizzes
  class SaveResponses
    def initialize(attempt:, responses:)
      @attempt = attempt
      @responses = responses
    end

    def call
      attempt.expire_if_needed!
      return failure("Attempt is not editable", "invalid_state") unless attempt.editable?

      QuizResponse.transaction do
        responses.each do |response_params|
          question = attempt.quiz.questions.find_by_uuid!(response_params[:question_uuid])
          record = attempt.quiz_responses.find_or_initialize_by(question: question)
          record.selected_option_uuids = Array(response_params[:selected_option_uuids]).compact.uniq
          record.save!
        end
      end

      ServiceResult::Base.success(attempt.reload)
    rescue ActiveRecord::RecordNotFound
      failure("Question not found", "not_found")
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
