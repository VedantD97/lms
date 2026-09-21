class UserPolicy < ApplicationPolicy
  def index?
    admin_or_above?
  end

  def show?
    admin_or_above? || owner?
  end

  def update?
    admin_or_above? || owner?
  end

  def destroy?
    super_admin? && !owner?
  end

  def assign_role?
    admin_or_above?
  end

  class Scope < Scope
    def resolve
      if user.admin_or_above?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end

  private

  def owner?
    user.id == record.id
  end
end
