module Api
  module V1
    class QuestionOptionSerializer < ApplicationSerializer
      attributes :uuid, :body, :is_correct, :position
    end
  end
end
