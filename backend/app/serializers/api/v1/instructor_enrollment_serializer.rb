module Api
  module V1
    class InstructorEnrollmentSerializer < ApplicationSerializer
      attributes :uuid, :status, :enrolled_at, :completed_at, :progress_percent

      attribute :course_uuid do |enrollment|
        enrollment.course.uuid
      end

      attribute :student do |enrollment|
        user = enrollment.user
        {
          uuid: user.uuid,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email
        }
      end

      attribute :progress_summary do |enrollment|
        Progress::CourseCompletion.new(enrollment: enrollment).summary
      end
    end
  end
end
