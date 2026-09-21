module Api
  module V1
    class StudentQuestionOptionSerializer < ApplicationSerializer
      attributes :uuid, :body, :position
    end
  end
end
