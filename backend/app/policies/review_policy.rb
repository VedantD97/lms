class ReviewPolicy < ApplicationPolicy
  def index?
    can_view_course_reviews?
  end

  def show?
    can_view_course_reviews?
  end

  def create?
    user&.student? || user&.admin_or_above?
  end

  def update?
    owns_review? || admin_or_above?
  end

  def destroy?
    owns_review? || admin_or_above?
  end

  class Scope < Scope
    def resolve
      if user.admin_or_above?
        scope.all
      else
        scope.joins(:course).merge(Course.catalog)
      end
    end
  end

  private

  def owns_review?
    record.user_id == user.id
  end

  def can_view_course_reviews?
    return true if admin_or_above?
    return true if record.is_a?(Review) && record.course.published?
    return true if record.is_a?(Course) && record.published?

    false
  end
end
