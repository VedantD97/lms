module Reports
  class CourseCompletionReport
    def initialize(scope: Course.manageable)
      @scope = scope
    end

    def call
      scope.includes(:enrollments).map do |course|
        enrollments = course.enrollments
        total = enrollments.size
        completed = enrollments.count { |enrollment| enrollment.completed? }
        completion_rate = total.positive? ? ((completed.to_f / total) * 100).round(2) : 0.0
        average_progress = total.positive? ? (enrollments.sum(&:progress_percent).to_f / total).round(2) : 0.0

        {
          course_uuid: course.uuid,
          course_title: course.title,
          status: course.status,
          total_enrollments: total,
          completed_enrollments: completed,
          active_enrollments: enrollments.count { |enrollment| enrollment.active? },
          completion_rate: completion_rate,
          average_progress: average_progress
        }
      end.sort_by { |row| -row[:total_enrollments] }
    end

    private

    attr_reader :scope
  end
end
