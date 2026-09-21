module Progress
  class RecalculateCourseProgress
    def initialize(enrollment:)
      @enrollment = enrollment
      @completion = CourseCompletion.new(enrollment: enrollment)
    end

    def call
      percent = completion.progress_percent
      became_completed = !enrollment.completed? && completion.complete?

      enrollment.update!(
        progress_percent: percent,
        status: completion.complete? ? :completed : :active,
        completed_at: completion.complete? ? (enrollment.completed_at || Time.current) : nil
      )

      if became_completed
        enrollment.reload
        Certificates::IssueCertificate.new(enrollment: enrollment).call
        notify_course_completed(enrollment.reload)
      end

      ServiceResult::Base.success(enrollment.reload)
    end

    private

    attr_reader :enrollment, :completion

    def notify_course_completed(enrollment)
      Notifications::CreateNotification.new(
        user: enrollment.user,
        notification_type: :course_completed,
        payload: {
          title: "Course completed",
          body: "Congratulations! You completed #{enrollment.course.title}.",
          course_uuid: enrollment.course.uuid,
          course_title: enrollment.course.title,
          enrollment_uuid: enrollment.uuid
        }
      ).call

      certificate = enrollment.certificate
      return unless certificate&.active?

      Notifications::CreateNotification.new(
        user: enrollment.user,
        notification_type: :certificate_issued,
        payload: {
          title: "Certificate issued",
          body: "Your certificate for #{enrollment.course.title} is ready.",
          course_uuid: enrollment.course.uuid,
          course_title: enrollment.course.title,
          certificate_uuid: certificate.uuid,
          certificate_number: certificate.certificate_number
        }
      ).call
    end
  end
end
