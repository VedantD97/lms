module Api
  module V1
    class QuizAttemptResultSerializer < ApplicationSerializer
      attributes :uuid, :attempt_number, :status, :started_at, :submitted_at, :expires_at,
                 :score, :max_score, :percentage, :passed, :time_spent_seconds

      attribute :quiz_uuid do |attempt|
        attempt.quiz.uuid
      end

      attribute :enrollment_uuid do |attempt|
        attempt.enrollment.uuid
      end

      attribute :show_correct_answers do |_attempt|
        params[:include_correct_answers] || false
      end

      attribute :responses do |attempt|
        attempt.quiz_responses.includes(:question).map do |response|
          payload = {
            question_uuid: response.question.uuid,
            selected_option_uuids: response.selected_option_uuids,
            is_correct: response.is_correct,
            points_awarded: response.points_awarded
          }

          if params[:include_correct_answers]
            payload[:correct_option_uuids] = response.question.correct_option_uuids
            payload[:explanation] = response.question.explanation
          end

          payload
        end
      end
    end
  end
end
