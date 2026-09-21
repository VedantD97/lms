module Api
  module V1
    class EnrollmentSerializer < ApplicationSerializer
      attributes :uuid, :status, :enrolled_at, :completed_at, :progress_percent

      attribute :course_uuid do |enrollment|
        enrollment.course.uuid
      end

      attribute :user_uuid do |enrollment|
        enrollment.user.uuid
      end
    end
  end
end
