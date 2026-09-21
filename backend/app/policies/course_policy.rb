class CoursePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    return true if admin_or_above?
    return true if record.instructor?(user)
    return true if record.published?

    false
  end

  def create?
    user&.instructor? || admin_or_above?
  end

  def update?
    admin_or_above? || record.instructor?(user)
  end

  def destroy?
    admin_or_above?
  end

  def assign_instructor?
    admin_or_above?
  end

  def remove_instructor?
    admin_or_above?
  end

  def publish?
    update?
  end

  def unpublish?
    update?
  end

  def archive?
    admin_or_above?
  end

  def view_enrollments?
    admin_or_above? || record.instructor?(user)
  end

  class Scope < Scope
    def resolve
      if user.admin_or_above?
        scope.all
      elsif user.instructor?
        scope.left_joins(:course_instructors)
             .where(course_instructors: { user_id: user.id })
             .distinct
      else
        scope.catalog
      end
    end
  end
end
