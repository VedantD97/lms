module Api
  module V1
    class QuizSerializer < ApplicationSerializer
      attributes :uuid, :title, :description, :status, :time_limit_minutes, :passing_score,
                 :max_attempts, :shuffle_questions, :shuffle_answers, :show_correct_answers,
                 :available_from, :available_until, :required_for_completion

      attribute :course_uuid do |quiz|
        quiz.course.uuid
      end

      attribute :lesson_uuid do |quiz|
        quiz.lesson&.uuid
      end

      attribute :question_count do |quiz|
        quiz.questions.size
      end
    end
  end
end
