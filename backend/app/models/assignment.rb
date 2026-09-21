class Assignment < ApplicationRecord
  include Identifiable
  include Publishable

  enum :status, { draft: 0, published: 1 }, validate: true

  belongs_to :course
  belongs_to :lesson, optional: true
  has_many :assignment_submissions, dependent: :destroy

  validates :title, presence: true
  validates :max_points, numericality: { greater_than: 0 }
  validates :passing_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :lesson_belongs_to_course

  scope :required_for_completion, -> { where(required_for_completion: true) }
  scope :open, lambda {
    where("due_at IS NULL OR due_at >= ?", Time.current)
  }

  def past_due?
    due_at.present? && Time.current > due_at
  end

  def accepting_submissions?
    published? && (!past_due? || allow_late?)
  end

  private

  def lesson_belongs_to_course
    return if lesson.blank?

    lesson_course = lesson.course_module&.course
    return if lesson_course&.id == course_id

    errors.add(:lesson, "must belong to the same course")
  end
end
