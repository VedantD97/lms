class ReportPolicy < ApplicationPolicy
  def dashboard?
    admin_or_above?
  end

  def enrollments?
    admin_or_above?
  end

  def course_completion?
    admin_or_above?
  end
end
