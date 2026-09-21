module Reports
  class DashboardSummary
    def call
      {
        users: user_counts,
        courses: course_counts,
        enrollments: enrollment_counts,
        certificates: certificate_counts,
        reviews: review_counts,
        recent_enrollments_30d: Enrollment.where(enrolled_at: 30.days.ago..).count
      }
    end

    private

    def user_counts
      {
        students: users_with_role("student"),
        instructors: users_with_role("instructor"),
        admins: users_with_role("admin") + users_with_role("super_admin")
      }
    end

    def users_with_role(role_name)
      User.joins(:roles).where(roles: { name: role_name }).distinct.count
    end

    def course_counts
      {
        total: Course.count,
        published: Course.published.count,
        draft: Course.where(status: :draft).count,
        archived: Course.archived.count
      }
    end

    def enrollment_counts
      {
        total: Enrollment.count,
        active: Enrollment.active.count,
        completed: Enrollment.completed.count,
        dropped: Enrollment.dropped.count
      }
    end

    def certificate_counts
      {
        total: Certificate.count,
        active: Certificate.active.count,
        revoked: Certificate.revoked.count
      }
    end

    def review_counts
      {
        total: Review.count,
        average_rating: Review.average(:rating)&.to_f&.round(2)
      }
    end
  end
end
