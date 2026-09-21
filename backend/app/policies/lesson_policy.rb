class LessonPolicy < ApplicationPolicy
  def show?
    course = record.course_module.course
    return true if admin_or_above? || course.instructor?(user)

    return true if course.published? && (record.is_preview || enrolled?(course))

    false
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

  private

  def can_manage_course?
    course = record.is_a?(Lesson) ? record.course_module.course : record.course_module&.course
    admin_or_above? || course.instructor?(user)
  end

  def enrolled?(course)
    user.enrollments.active.exists?(course_id: course.id)
  end
end
