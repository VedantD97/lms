class StudentDashboardPolicy < ApplicationPolicy
  def show?
    user&.student? || user&.admin_or_above?
  end
end
