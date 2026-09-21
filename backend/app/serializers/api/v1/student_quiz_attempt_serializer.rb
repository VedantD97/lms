module Api
  module V1
    class StudentQuizAttemptSerializer < ApplicationSerializer
      attributes :uuid, :attempt_number, :status, :started_at, :expires_at

      attribute :quiz_uuid do |attempt|
        attempt.quiz.uuid
      end

      attribute :enrollment_uuid do |attempt|
        attempt.enrollment.uuid
      end

      attribute :questions do |attempt|
        attempt.ordered_questions.map do |question|
          payload = JSON.parse(Api::V1::StudentQuestionSerializer.render(question))
          if attempt.metadata["shuffle_answers"]
            payload["question_options"] = payload["question_options"].shuffle
          end
          payload
        end
      end

      attribute :responses do |attempt|
        attempt.quiz_responses.map do |response|
          {
            question_uuid: response.question.uuid,
            selected_option_uuids: response.selected_option_uuids
          }
        end
      end
    end
  end
end
