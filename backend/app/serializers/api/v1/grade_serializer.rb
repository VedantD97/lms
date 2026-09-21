module Api
  module V1
    class GradeSerializer < ApplicationSerializer
      attributes :uuid, :points, :percentage, :passed, :feedback, :graded_at

      attribute :graded_by do |grade|
        user = grade.graded_by
        {
          uuid: user.uuid,
          first_name: user.first_name,
          last_name: user.last_name
        }
      end
    end
  end
end
