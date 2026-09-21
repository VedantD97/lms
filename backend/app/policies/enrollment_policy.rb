class EnrollmentPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    admin_or_above? || owner? || instructor_for_course?
  end

  def create?
    admin_or_above? || owner_for_create?
  end

  def destroy?
    admin_or_above?
  end

  def progress?
    show?
  end

  class Scope < Scope
    def resolve
      if user.admin_or_above?
        scope.all
      elsif user.instructor?
        scope.joins(:course).merge(Course.where(id: user.instructed_courses.select(:id)))
      else
        scope.where(user_id: user.id)
      end
    end
  end

  private

  def owner?
    record.user_id == user.id
  end

  def owner_for_create?
    user.student?
  end

  def instructor_for_course?
    user.instructor? && record.course.instructor?(user)
  end
end
