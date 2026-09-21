class LessonProgress < ApplicationRecord
  enum :status, { not_started: 0, in_progress: 1, completed: 2 }, validate: true

  belongs_to :enrollment
  belongs_to :lesson

  validates :lesson_id, uniqueness: { scope: :enrollment_id }
  validates :progress_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :last_position_seconds, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :lesson_belongs_to_enrolled_course

  scope :completed, -> { where(status: statuses[:completed]) }

  private

  def lesson_belongs_to_enrolled_course
    return if enrollment.blank? || lesson.blank?
    return if lesson.course_module.course_id == enrollment.course_id

    errors.add(:lesson, "must belong to the enrolled course")
  end
end
