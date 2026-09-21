module Positionable
  extend ActiveSupport::Concern

  included do
    before_validation :assign_default_position, on: :create
  end

  private

  def assign_default_position
    return if position.present? && position.positive?

    scope = position_scope
    return if scope.blank?

    self.position = (scope.maximum(:position) || -1) + 1
  end

  def position_scope
    raise NotImplementedError, "#{self.class} must implement #position_scope"
  end
end
