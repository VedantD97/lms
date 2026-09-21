module Api
  module V1
    class StudentEnrollmentSerializer < ApplicationSerializer
      attributes :uuid, :status, :enrolled_at, :completed_at, :progress_percent

      attribute :course do |enrollment|
        course = enrollment.course
        {
          uuid: course.uuid,
          title: course.title,
          slug: course.slug,
          short_description: course.short_description,
          level: course.level,
          duration_minutes: course.duration_minutes
        }
      end

      attribute :continue_learning do |enrollment|
        result = Progress::ContinueLearning.new(enrollment: enrollment).call
        result.data
      end

      attribute :progress_summary do |enrollment|
        Progress::CourseCompletion.new(enrollment: enrollment).summary
      end

      attribute :certificate do |enrollment|
        certificate = enrollment.certificate
        next unless certificate&.active?

        {
          uuid: certificate.uuid,
          certificate_number: certificate.certificate_number,
          issued_at: certificate.issued_at
        }
      end
    end
  end
end
