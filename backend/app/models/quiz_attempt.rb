class QuizAttempt < ApplicationRecord
  include Identifiable

  enum :status, { in_progress: 0, submitted: 1, expired: 2 }, validate: true

  belongs_to :quiz
  belongs_to :enrollment
  has_many :quiz_responses, dependent: :destroy

  validates :attempt_number, numericality: { only_integer: true, greater_than: 0 }
  validates :attempt_number, uniqueness: { scope: %i[quiz_id enrollment_id] }
  validates :started_at, presence: true

  scope :for_enrollment, ->(enrollment) { where(enrollment: enrollment) }
  scope :completed, -> { where(status: %i[submitted expired]) }

  def editable?
    in_progress? && !expired_by_time?
  end

  def expired_by_time?
    expires_at.present? && Time.current >= expires_at
  end

  def expire_if_needed!
    return unless in_progress? && expired_by_time?

    update!(status: :expired)
  end

  def ordered_questions
    return quiz.questions.ordered if question_order.blank?

    questions_by_uuid = quiz.questions.includes(:question_options).index_by(&:uuid)
    question_order.filter_map { |uuid| questions_by_uuid[uuid] }
  end
end
