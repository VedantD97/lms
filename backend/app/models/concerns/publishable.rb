module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where(status: statuses[:published]) }
    scope :draft, -> { where(status: statuses[:draft]) }
  end
end
