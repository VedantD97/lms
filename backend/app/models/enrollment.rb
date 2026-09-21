class Enrollment < ApplicationRecord
  include Identifiable

  enum :status, { active: 0, completed: 1, dropped: 2, expired: 3 }, validate: true

  belongs_to :user
  belongs_to :course
  has_many :lesson_progresses, dependent: :destroy
  has_many :assignment_submissions, dependent: :destroy
  has_many :quiz_attempts, dependent: :destroy
  has_one :certificate, dependent: :destroy

  validates :enrolled_at, presence: true
  validates :user_id, uniqueness: { scope: :course_id, message: "is already enrolled in this course" }
  validates :progress_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :user_must_be_student_role
  validate :course_must_be_enrollable

  scope :for_user, ->(user) { where(user: user) }

  private

  def user_must_be_student_role
    return if user.blank?
    return if user.student? || user.admin_or_above?

    errors.add(:user, "must have student role")
  end

  def course_must_be_enrollable
    return if course.blank?
    return if course.published?

    errors.add(:course, "must be published")
  end
end
