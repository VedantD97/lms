class CourseModulePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    course_accessible?
  end

  def create?
    can_manage_course?
  end

  def update?
    can_manage_course?
  end

  def destroy?
    can_manage_course?
  end

  def reorder?
    can_manage_course?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def course
    record.is_a?(Course) ? record : record.course
  end

  def course_accessible?
    CoursePolicy.new(user, course).show?
  end

  def can_manage_course?
    admin_or_above? || course.instructor?(user)
  end
end
