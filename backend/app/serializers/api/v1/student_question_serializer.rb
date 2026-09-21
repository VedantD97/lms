module Api
  module V1
    class StudentQuestionSerializer < ApplicationSerializer
      attributes :uuid, :question_type, :body, :points, :position

      attribute :question_options do |question|
        question.question_options.ordered.map do |option|
          JSON.parse(Api::V1::StudentQuestionOptionSerializer.render(option))
        end
      end
    end
  end
end
