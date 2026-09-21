class QuestionOption < ApplicationRecord
  include Identifiable
  include Orderable

  belongs_to :question

  validates :body, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:position, :created_at) }
end
