class InstructorDashboardPolicy < ApplicationPolicy
  def show?
    user&.instructor? || user&.admin_or_above?
  end
end
