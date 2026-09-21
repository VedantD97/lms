module Api
  module V1
    class StudentQuizSerializer < ApplicationSerializer
      attributes :uuid, :title, :description, :time_limit_minutes, :passing_score,
                 :max_attempts, :available_from, :available_until

      attribute :question_count do |quiz|
        quiz.questions.size
      end

      attribute :attempts_used, if: proc { params.present? } do |_quiz|
        params[:attempts_used] || 0
      end

      attribute :attempts_remaining, if: proc { params.present? } do |_quiz|
        params[:attempts_remaining]
      end

      attribute :best_percentage, if: proc { params.present? } do |_quiz|
        params[:best_percentage]
      end

      attribute :has_in_progress_attempt, if: proc { params.present? } do |_quiz|
        params[:has_in_progress_attempt] || false
      end

      attribute :in_progress_attempt_uuid, if: proc { params.present? } do |_quiz|
        params[:in_progress_attempt_uuid]
      end

      attributes :required_for_completion

      attribute :passed, if: proc { params.present? } do |_quiz|
        params[:passed] || false
      end
    end
  end
end
