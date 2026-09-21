module Api
  module V1
    class StudentAssignmentSubmissionSerializer < ApplicationSerializer
      attributes :uuid, :body, :submitted_at, :status, :late

      attribute :assignment_uuid do |submission|
        submission.assignment.uuid
      end

      attribute :grade do |submission|
        next unless submission.graded? && submission.grade

        JSON.parse(Api::V1::GradeSerializer.render(submission.grade))
      end
    end
  end
end
