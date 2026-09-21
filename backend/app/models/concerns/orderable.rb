module Orderable
  extend ActiveSupport::Concern

  included do
    scope :ordered, -> { order(:position, :created_at) }
  end
end
