module Student
  class DashboardSummary
    def initialize(student:)
      @student = student
    end

    def call
      enrollments = student.enrollments.includes(:course, :certificate)
      active_enrollments = enrollments.active

      {
        enrollments: enrollment_counts(enrollments),
        certificates: certificate_counts(student),
        notifications: { unread_count: student.notifications.unread.count },
        average_progress: average_progress(active_enrollments),
        continue_learning: continue_learning_items(active_enrollments),
        pending_actions: pending_actions(active_enrollments),
        recent_notifications: recent_notifications
      }
    end

    private

    attr_reader :student

    def enrollment_counts(enrollments)
      {
        total: enrollments.count,
        active: enrollments.active.count,
        completed: enrollments.completed.count
      }
    end

    def certificate_counts(student)
      certificates = Certificate.joins(:enrollment).where(enrollments: { user_id: student.id })
      {
        total: certificates.count,
        active: certificates.merge(Certificate.active).count
      }
    end

    def average_progress(active_enrollments)
      return 0.0 if active_enrollments.empty?

      (active_enrollments.sum(&:progress_percent).to_f / active_enrollments.size).round(2)
    end

    def continue_learning_items(active_enrollments)
      active_enrollments.filter_map do |enrollment|
        continue = Progress::ContinueLearning.new(enrollment: enrollment).call.data
        next unless continue

        {
          enrollment_uuid: enrollment.uuid,
          course_uuid: enrollment.course.uuid,
          course_title: enrollment.course.title,
          lesson_uuid: continue[:lesson_uuid],
          lesson_title: continue[:lesson_title],
          module_title: continue[:module_title],
          progress_percent: continue[:progress_percent]
        }
      end
    end

    def pending_actions(active_enrollments)
      quizzes = 0
      assignments = 0

      active_enrollments.each do |enrollment|
        summary = Progress::CourseCompletion.new(enrollment: enrollment).summary
        quizzes += summary[:total_quizzes] - summary[:passed_quizzes]
        assignments += summary[:total_assignments] - summary[:passed_assignments]
      end

      { quizzes: quizzes, assignments: assignments }
    end

    def recent_notifications
      student.notifications.recent.limit(5).map do |notification|
        {
          uuid: notification.uuid,
          notification_type: notification.notification_type,
          title: notification.payload["title"],
          body: notification.payload["body"],
          read: notification.read?,
          created_at: notification.created_at
        }
      end
    end
  end
end
