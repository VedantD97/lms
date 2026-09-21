module Api
  module V1
    class QuizDetailSerializer < ApplicationSerializer
      attributes :uuid, :title, :description, :status, :time_limit_minutes, :passing_score,
                 :max_attempts, :shuffle_questions, :shuffle_answers, :show_correct_answers,
                 :available_from, :available_until, :required_for_completion

      attribute :course_uuid do |quiz|
        quiz.course.uuid
      end

      attribute :lesson_uuid do |quiz|
        quiz.lesson&.uuid
      end

      attribute :total_points do |quiz|
        quiz.total_points
      end

      attribute :questions do |quiz|
        quiz.questions.ordered.map do |question|
          JSON.parse(Api::V1::QuestionSerializer.render(question))
        end
      end
    end
  end
end
