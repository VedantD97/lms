class AuditLogPolicy < ApplicationPolicy
  def index?
    super_admin?
  end

  def show?
    super_admin?
  end

  class Scope < Scope
    def resolve
      raise Pundit::NotAuthorizedError unless user.super_admin?

      scope.all
    end
  end
end
