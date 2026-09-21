class AssignmentSubmissionPolicy < ApplicationPolicy
  def show?
    owns_submission? || can_manage_assignment?
  end

  def submit?
    owns_enrollment? && record.assignment.published?
  end

  def grade?
    can_manage_assignment?
  end

  def index?
    user.instructor? || admin_or_above?
  end

  def pending?
    index?
  end

  class Scope < Scope
    def resolve
      if user.admin_or_above?
        scope.all
      elsif user.instructor?
        scope.joins(assignment: :course).merge(Course.where(id: user.instructed_courses.select(:id)))
      elsif user.student?
        scope.joins(:enrollment).merge(Enrollment.where(user_id: user.id))
      else
        scope.none
      end
    end
  end

  private

  def owns_submission?
    user.enrollments.exists?(id: record.enrollment_id)
  end

  def owns_enrollment?
    user.enrollments.active.exists?(id: record.enrollment_id)
  end

  def can_manage_assignment?
    admin_or_above? || record.assignment.course.instructor?(user)
  end
end
