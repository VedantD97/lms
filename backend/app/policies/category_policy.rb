class CategoryPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    admin_or_above?
  end

  def update?
    admin_or_above?
  end

  def destroy?
    admin_or_above?
  end

  class Scope < Scope
    def resolve
      scope.order(:position, :name)
    end
  end
end
