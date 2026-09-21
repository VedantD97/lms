module Api
  module V1
    class AssignmentDetailSerializer < ApplicationSerializer
      attributes :uuid, :title, :description, :status, :due_at, :max_points, :passing_score,
                 :allow_late, :allow_resubmit, :required_for_completion

      attribute :course_uuid do |assignment|
        assignment.course.uuid
      end

      attribute :lesson_uuid do |assignment|
        assignment.lesson&.uuid
      end

      attribute :submission_count do |assignment|
        assignment.assignment_submissions.count
      end
    end
  end
end
