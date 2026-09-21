class CourseInstructor < ApplicationRecord
  belongs_to :course
  belongs_to :user

  enum :role, { lead: 0, assistant: 1 }, validate: true

  validates :user_id, uniqueness: { scope: :course_id }
  validate :user_must_be_instructor

  private

  def user_must_be_instructor
    return if user.blank?
    return if user.instructor? || user.admin_or_above?

    errors.add(:user, "must have instructor or admin role")
  end
end
