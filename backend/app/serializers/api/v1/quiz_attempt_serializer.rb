module Api
  module V1
    class QuizAttemptSerializer < ApplicationSerializer
      attributes :uuid, :attempt_number, :status, :started_at, :expires_at, :submitted_at,
                 :score, :max_score, :percentage, :passed, :time_spent_seconds,
                 :quiz_uuid, :enrollment_uuid

      def quiz_uuid
        object.quiz.uuid
      end

      def enrollment_uuid
        object.enrollment.uuid
      end
    end
  end
end
