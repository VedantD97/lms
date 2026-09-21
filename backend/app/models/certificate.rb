class Certificate < ApplicationRecord
  include Identifiable

  belongs_to :enrollment
  has_one :user, through: :enrollment
  has_one :course, through: :enrollment

  validates :certificate_number, presence: true, uniqueness: true
  validates :issued_at, presence: true
  validates :enrollment_id, uniqueness: true

  scope :active, -> { where(revoked_at: nil) }
  scope :revoked, -> { where.not(revoked_at: nil) }

  def revoked?
    revoked_at.present?
  end

  def active?
    !revoked?
  end
end
