class Notification < ApplicationRecord
  include Identifiable

  enum :notification_type, {
    assignment_graded: 0,
    course_completed: 1,
    certificate_issued: 2,
    announcement: 3
  }, validate: true

  belongs_to :user

  validates :payload, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def read?
    read_at.present?
  end

  def mark_read!
    update!(read_at: Time.current) unless read?
  end
end
