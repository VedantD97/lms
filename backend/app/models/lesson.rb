class Lesson < ApplicationRecord
  include Identifiable
  include Publishable
  include Orderable
  include Positionable

  enum :status, { draft: 0, published: 1 }, validate: true
  enum :content_type, { video: 0, document: 1, text: 2, mixed: 3 }, validate: true

  belongs_to :course_module
  has_one :course, through: :course_module
  has_many :lesson_resources, dependent: :destroy
  has_many :lesson_progresses, dependent: :destroy
  has_many :quizzes, dependent: :destroy
  has_many :assignments, dependent: :destroy

  validates :title, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :duration_seconds, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :clear_required_for_preview
  validate :preview_not_required_for_completion

  scope :required_for_completion, -> { where(required_for_completion: true) }

  private

  def clear_required_for_preview
    self.required_for_completion = false if is_preview?
  end

  def preview_not_required_for_completion
    return unless is_preview? && required_for_completion?

    errors.add(:required_for_completion, "cannot be required for preview lessons")
  end

  def position_scope
    return nil if course_module.blank?

    course_module.lessons
  end
end
