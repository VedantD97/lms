module Reports
  class EnrollmentsReport
    def initialize(scope: Enrollment.all, from: nil, to: nil, course: nil, status: nil)
      @scope = scope.includes(:course)
      @from = from
      @to = to
      @course = course
      @status = status
    end

    def call
      filtered = apply_filters(scope)

      {
        summary: summary_for(filtered),
        by_course: by_course(filtered),
        recent: recent_trend(filtered)
      }
    end

    private

    attr_reader :scope, :from, :to, :course, :status

    def apply_filters(relation)
      relation = relation.where(enrolled_at: from..) if from.present?
      relation = relation.where(enrolled_at: ..to) if to.present?
      relation = relation.where(course: course) if course.present?
      relation = relation.where(status: status) if status.present?
      relation
    end

    def summary_for(relation)
      grouped = relation.group(:status).count
      {
        total: grouped.values.sum,
        active: grouped.fetch(Enrollment.statuses[:active], 0),
        completed: grouped.fetch(Enrollment.statuses[:completed], 0),
        dropped: grouped.fetch(Enrollment.statuses[:dropped], 0),
        expired: grouped.fetch(Enrollment.statuses[:expired], 0)
      }
    end

    def by_course(relation)
      relation.joins(:course)
              .group("courses.id", "courses.uuid", "courses.title")
              .order(Arel.sql("COUNT(*) DESC"))
              .pluck(
                "courses.uuid",
                "courses.title",
                Arel.sql("COUNT(*)"),
                Arel.sql("COUNT(*) FILTER (WHERE enrollments.status = #{Enrollment.statuses[:active]})"),
                Arel.sql("COUNT(*) FILTER (WHERE enrollments.status = #{Enrollment.statuses[:completed]})"),
                Arel.sql("COUNT(*) FILTER (WHERE enrollments.status = #{Enrollment.statuses[:dropped]})")
              )
              .map do |course_uuid, course_title, total, active, completed, dropped|
        {
          course_uuid: course_uuid,
          course_title: course_title,
          total: total,
          active: active,
          completed: completed,
          dropped: dropped
        }
      end
    end

    def recent_trend(relation)
      relation.where(enrolled_at: 30.days.ago..)
              .group(Arel.sql("DATE(enrolled_at)"))
              .order(Arel.sql("DATE(enrolled_at)"))
              .count
              .map { |date, count| { date: date.to_s, count: count } }
    end
  end
end
