module Api
  module V1
    class StudentAssignmentSerializer < ApplicationSerializer
      attributes :uuid, :title, :description, :due_at, :max_points, :passing_score,
                 :allow_late, :allow_resubmit, :required_for_completion

      attribute :course_uuid do |assignment|
        assignment.course.uuid
      end

      attribute :past_due do |assignment|
        assignment.past_due?
      end

      attribute :accepting_submissions do |assignment|
        assignment.accepting_submissions?
      end

      attribute :submission_status, if: proc { params.present? } do |_assignment|
        params[:submission_status]
      end

      attribute :submitted_at, if: proc { params.present? } do |_assignment|
        params[:submitted_at]
      end

      attribute :passed, if: proc { params.present? } do |_assignment|
        params[:passed] || false
      end

      attribute :grade_percentage, if: proc { params.present? } do |_assignment|
        params[:grade_percentage]
      end

      attribute :submission_uuid, if: proc { params.present? } do |_assignment|
        params[:submission_uuid]
      end
    end
  end
end
