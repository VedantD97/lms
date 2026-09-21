class AssignmentSubmission < ApplicationRecord
  include Identifiable

  enum :status, { submitted: 0, graded: 1 }, validate: true

  belongs_to :assignment
  belongs_to :enrollment
  has_one :grade, as: :gradable, dependent: :destroy

  validates :assignment_id, uniqueness: { scope: :enrollment_id }
  validate :assignment_belongs_to_enrolled_course

  scope :for_enrollment, ->(enrollment) { where(enrollment: enrollment) }
  scope :passed, -> { joins(:grade).where(grades: { passed: true }) }

  def passed?
    graded? && grade&.passed?
  end

  private

  def assignment_belongs_to_enrolled_course
    return if assignment.blank? || enrollment.blank?
    return if assignment.course_id == enrollment.course_id

    errors.add(:assignment, "must belong to the enrolled course")
  end
end
