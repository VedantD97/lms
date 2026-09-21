class AssignmentPolicy < ApplicationPolicy
  def index?
    admin_or_above? || user.instructor?
  end

  def show?
    can_manage? || can_submit?
  end

  def submit?
    can_submit?
  end

  def create?
    can_manage_course?
  end

  def update?
    can_manage?
  end

  def destroy?
    can_manage?
  end

  def publish?
    can_manage?
  end

  def unpublish?
    can_manage?
  end

  def view_submissions?
    can_manage?
  end

  class Scope < Scope
    def resolve
      if user.admin_or_above?
        scope.all
      elsif user.instructor?
        scope.joins(:course).merge(Course.where(id: user.instructed_courses.select(:id)))
      elsif user.student?
        scope.published.joins(:course).merge(
          Course.published.where(id: user.enrollments.active.select(:course_id))
        )
      else
        scope.none
      end
    end
  end

  private

  def can_manage?
    admin_or_above? || record.course.instructor?(user)
  end

  def can_manage_course?
    course = record.is_a?(Assignment) ? record.course : record.course
    admin_or_above? || course.instructor?(user)
  end

  def can_submit?
    return false unless user.student? || user.admin_or_above?
    return false unless record.published?

    user.enrollments.active.exists?(course_id: record.course_id)
  end
end
