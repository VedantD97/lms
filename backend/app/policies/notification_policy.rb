class NotificationPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    owns_notification?
  end

  def read?
    owns_notification?
  end

  def read_all?
    user.present?
  end

  def unread_count?
    user.present?
  end

  class Scope < Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end

  private

  def owns_notification?
    record.user_id == user.id
  end
end
