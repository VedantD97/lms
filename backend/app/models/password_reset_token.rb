class PasswordResetToken < ApplicationRecord
  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :usable, -> { where(used_at: nil).where("expires_at > ?", Time.current) }

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token)
  end

  def use!
    update!(used_at: Time.current)
  end

  def usable?
    used_at.nil? && expires_at > Time.current
  end
end
