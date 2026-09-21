class Question < ApplicationRecord
  include Identifiable
  include Orderable
  include Positionable

  enum :question_type, { single_choice: 0, multiple_choice: 1, true_false: 2 }, validate: true

  belongs_to :quiz
  has_many :question_options, dependent: :destroy
  has_many :quiz_responses, dependent: :destroy

  validates :body, presence: true
  validates :points, numericality: { greater_than_or_equal_to: 0 }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :options_match_question_type, if: -> { question_options.loaded? ? question_options.any? : question_options.exists? }

  after_create :create_true_false_options, if: :true_false?

  def correct_option_uuids
    question_options.where(is_correct: true).pluck(:uuid)
  end

  private

  def position_scope
    quiz&.questions
  end

  def create_true_false_options
    return if question_options.exists?

    question_options.create!([
      { body: "True", is_correct: true, position: 0 },
      { body: "False", is_correct: false, position: 1 }
    ])
  end

  def options_match_question_type
    return if question_options.empty?

    correct_count = question_options.count(&:is_correct)

    case question_type
    when "single_choice", "true_false"
      errors.add(:base, "must have exactly one correct option") unless correct_count == 1
    when "multiple_choice"
      errors.add(:base, "must have at least one correct option") if correct_count.zero?
    end
  end
end
