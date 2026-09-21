module Api
  module V1
    class AssignmentSubmissionSerializer < ApplicationSerializer
      attributes :uuid, :body, :submitted_at, :status, :late

      attribute :enrollment_uuid do |submission|
        submission.enrollment.uuid
      end

      attribute :assignment_uuid do |submission|
        submission.assignment.uuid
      end

      attribute :student do |submission|
        user = submission.enrollment.user
        {
          uuid: user.uuid,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email
        }
      end

      attribute :grade do |submission|
        next unless submission.grade

        JSON.parse(Api::V1::GradeSerializer.render(submission.grade))
      end
    end
  end
end
