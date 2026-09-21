module Instructor
  class DashboardSummary
    def initialize(instructor:)
      @instructor = instructor
    end

    def call
      courses = instructor.instructed_courses
      course_ids = courses.select(:id)
      enrollments = Enrollment.where(course_id: course_ids)
      pending_submissions = pending_submissions_scope.count

      {
        courses: course_counts(courses),
        enrollments: enrollment_counts(enrollments),
        pending_submissions: pending_submissions,
        recent_enrollments_30d: enrollments.where(enrolled_at: 30.days.ago..).count,
        course_breakdown: course_breakdown(courses, enrollments)
      }
    end

    private

    attr_reader :instructor

    def course_counts(courses)
      {
        total: courses.count,
        published: courses.published.count,
        draft: courses.where(status: :draft).count
      }
    end

    def enrollment_counts(enrollments)
      {
        total: enrollments.count,
        active: enrollments.active.count,
        completed: enrollments.completed.count
      }
    end

    def pending_submissions_scope
      AssignmentSubmissionPolicy::Scope.new(instructor, AssignmentSubmission).resolve
        .where(status: :submitted)
        .left_joins(:grade)
        .where(grades: { id: nil })
    end

    def course_breakdown(courses, enrollments)
      enrollment_counts_by_course = enrollments.group(:course_id).count

      courses.map do |course|
        {
          course_uuid: course.uuid,
          course_title: course.title,
          status: course.status,
          enrollments: enrollment_counts_by_course.fetch(course.id, 0),
          pending_submissions: pending_for_course(course)
        }
      end.sort_by { |row| -row[:enrollments] }
    end

    def pending_for_course(course)
      AssignmentSubmission.joins(:assignment)
                          .where(assignments: { course_id: course.id }, status: :submitted)
                          .left_joins(:grade)
                          .where(grades: { id: nil })
                          .count
    end
  end
end
