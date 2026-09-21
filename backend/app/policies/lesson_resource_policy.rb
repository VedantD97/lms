class LessonResourcePolicy < ApplicationPolicy
  def create?
    can_manage_lesson?
  end

  def destroy?
    can_manage_lesson?
  end

  def show?
    can_access_lesson?
  end

  def download?
    can_access_lesson?
  end

  private

  def can_manage_lesson?
    course = record.lesson.course_module.course
    admin_or_above? || course.instructor?(user)
  end

  def can_access_lesson?
    return true if can_manage_lesson?

    lesson = record.lesson
    course = lesson.course_module.course
    return true if lesson.is_preview && course.published?

    user.enrollments.active.exists?(course_id: course.id) &&
      LessonPolicy.new(user, lesson).show?
  end
end
