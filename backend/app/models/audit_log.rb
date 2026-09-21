class AuditLog < ApplicationRecord
  include Identifiable

  belongs_to :actor, class_name: "User"
  belongs_to :auditable, polymorphic: true, optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
