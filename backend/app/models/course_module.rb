class CourseModule < ApplicationRecord
  include Identifiable
  include Publishable
  include Orderable
  include Positionable

  enum :status, { draft: 0, published: 1 }, validate: true

  belongs_to :course
  has_many :lessons, dependent: :destroy

  validates :title, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  private

  def position_scope
    return nil if course.blank?

    course.course_modules
  end
end
