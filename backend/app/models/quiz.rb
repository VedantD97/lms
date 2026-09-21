class Quiz < ApplicationRecord
  include Identifiable
  include Publishable

  enum :status, { draft: 0, published: 1 }, validate: true
  enum :show_correct_answers, { never: 0, after_submit: 1 }, validate: true

  belongs_to :course
  belongs_to :lesson, optional: true
  has_many :questions, dependent: :destroy
  has_many :quiz_attempts, dependent: :destroy

  validates :title, presence: true
  validates :passing_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :max_attempts, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :time_limit_minutes, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :lesson_belongs_to_course

  scope :required_for_completion, -> { where(required_for_completion: true) }

  scope :available, lambda {
    now = Time.current
    where("(available_from IS NULL OR available_from <= ?) AND (available_until IS NULL OR available_until >= ?)", now, now)
  }

  def total_points
    questions.sum(:points)
  end

  def available?
    now = Time.current
    (available_from.nil? || available_from <= now) && (available_until.nil? || available_until >= now)
  end

  def unlimited_attempts?
    max_attempts.zero?
  end

  private

  def lesson_belongs_to_course
    return if lesson.blank?

    lesson_course = lesson.course_module&.course
    return if lesson_course&.id == course_id

    errors.add(:lesson, "must belong to the same course")
  end
end
