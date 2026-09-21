class Review < ApplicationRecord
  include Identifiable

  belongs_to :course
  belongs_to :user

  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :user_id, uniqueness: { scope: :course_id, message: "has already reviewed this course" }
  validate :user_must_be_enrolled

  scope :recent, -> { order(created_at: :desc) }

  private

  def user_must_be_enrolled
    return if user.blank? || course.blank?
    return if user.enrollments.where(course_id: course_id, status: %i[active completed]).exists?

    errors.add(:user, "must be enrolled in the course to review it")
  end
end
