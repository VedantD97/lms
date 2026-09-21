module Api
  module V1
    class QuestionSerializer < ApplicationSerializer
      attributes :uuid, :question_type, :body, :points, :position, :explanation

      attribute :quiz_uuid do |question|
        question.quiz.uuid
      end

      attribute :question_options do |question|
        question.question_options.ordered.map do |option|
          JSON.parse(Api::V1::QuestionOptionSerializer.render(option))
        end
      end
    end
  end
end
