module Api
  module V1
    class InstructorPendingSubmissionSerializer < ApplicationSerializer
      attributes :uuid, :body, :submitted_at, :status, :late

      attribute :enrollment_uuid do |submission|
        submission.enrollment.uuid
      end

      attribute :assignment_uuid do |submission|
        submission.assignment.uuid
      end

      attribute :assignment_title do |submission|
        submission.assignment.title
      end

      attribute :course_uuid do |submission|
        submission.assignment.course.uuid
      end

      attribute :course_title do |submission|
        submission.assignment.course.title
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
    end
  end
end
