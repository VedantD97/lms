class LessonProgressPolicy < ApplicationPolicy
  def update?
    owner_enrollment?
  end

  def complete?
    owner_enrollment?
  end

  private

  def owner_enrollment?
    record.enrollment.user_id == user.id
  end
end
