class CertificatePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    owns_certificate? || admin_or_above?
  end

  def revoke?
    admin_or_above?
  end

  class Scope < Scope
    def resolve
      if user.admin_or_above?
        scope.all
      elsif user.student?
        scope.active.joins(:enrollment).merge(Enrollment.where(user_id: user.id))
      else
        scope.none
      end
    end
  end

  private

  def owns_certificate?
    user.enrollments.exists?(id: record.enrollment_id)
  end
end
