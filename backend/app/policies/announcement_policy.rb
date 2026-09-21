class AnnouncementPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    can_manage? || visible_to_student?
  end

  def create?
    return admin_or_above? if record.global?

    record.course.present? && (admin_or_above? || record.course.instructor?(user))
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

  class Scope < Scope
    def resolve
      if user.admin_or_above?
        scope.all
      elsif user.instructor?
        scope.where(author_id: user.id)
             .or(scope.where(course_id: user.instructed_courses.select(:id)))
      elsif user.student?
        published = scope.published
        course_ids = user.enrollments.active.select(:course_id)
        published.global.or(published.course.where(course_id: course_ids))
      else
        scope.none
      end
    end
  end

  private

  def can_manage?
    admin_or_above? || record.author_id == user.id ||
      (record.course.present? && record.course.instructor?(user))
  end

  def visible_to_student?
    return false unless user.student? || user.admin_or_above?
    return false unless record.published?

    record.global? || user.enrollments.active.exists?(course_id: record.course_id)
  end
end
