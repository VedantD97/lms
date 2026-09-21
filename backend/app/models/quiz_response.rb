class QuizResponse < ApplicationRecord
  include Identifiable

  belongs_to :quiz_attempt
  belongs_to :question

  validates :selected_option_uuids, presence: true, if: -> { question&.single_choice? || question&.multiple_choice? || question&.true_false? }
  validates :question_id, uniqueness: { scope: :quiz_attempt_id }

  validate :selected_options_belong_to_question

  private

  def selected_options_belong_to_question
    return if selected_option_uuids.blank? || question.blank?

    valid_uuids = question.question_options.pluck(:uuid)
    invalid = selected_option_uuids - valid_uuids
    return if invalid.empty?

    errors.add(:selected_option_uuids, "contains invalid options")
  end
end
