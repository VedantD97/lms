module Api
  module V1
    module Student
      class QuizAttemptsController < BaseController
        before_action :set_attempt

        def show
          authorize @attempt
          @attempt.expire_if_needed!
          render_data(JSON.parse(Api::V1::StudentQuizAttemptSerializer.render(@attempt)))
        end

        def save_responses
          authorize @attempt, :save_responses?
          return render_parameter_missing(ActionController::ParameterMissing.new("responses")) if response_params.empty?

          result = Quizzes::SaveResponses.new(
            attempt: @attempt,
            responses: response_params
          ).call
          return render_service_failure(result) if result.failure?

          render_data(JSON.parse(Api::V1::StudentQuizAttemptSerializer.render(result.data)))
        end

        def submit
          authorize @attempt, :submit?
          result = Quizzes::SubmitAttempt.new(
            attempt: @attempt,
            responses: response_params.presence
          ).call
          return render_service_failure(result) if result.failure?

          render_data(
            JSON.parse(
              Api::V1::QuizAttemptResultSerializer.render(
                result.data,
                params: { include_correct_answers: include_correct_answers?(result.data) }
              )
            )
          )
        end

        def results
          authorize @attempt, :results?
          render_data(
            JSON.parse(
              Api::V1::QuizAttemptResultSerializer.render(
                @attempt,
                params: { include_correct_answers: include_correct_answers?(@attempt) }
              )
            )
          )
        end

        private

        def set_attempt
          @attempt = QuizAttempt.includes(
            quiz: { questions: :question_options },
            quiz_responses: :question,
            enrollment: :user
          ).find_by_uuid!(params[:uuid])
        end

        def response_params
          return [] unless params.key?(:responses)

          Array(params[:responses]).map do |response|
            response.permit(:question_uuid, selected_option_uuids: []).to_h.symbolize_keys
          end
        end

        def include_correct_answers?(attempt)
          attempt.submitted? && attempt.quiz.show_correct_answers == "after_submit"
        end
      end
    end
  end
end
