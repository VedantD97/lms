class Announcement < ApplicationRecord
  include Identifiable

  enum :audience, { global: 0, course: 1 }, validate: true

  belongs_to :author, class_name: "User"
  belongs_to :course, optional: true

  validates :title, presence: true
  validates :body, presence: true
  validates :course, presence: true, if: :course?
  validate :course_required_for_course_audience

  scope :published, -> { where.not(published_at: nil) }
  scope :draft, -> { where(published_at: nil) }

  def published?
    published_at.present?
  end

  private

  def course_required_for_course_audience
    return unless course? && course.blank?

    errors.add(:course, "must be present for course announcements")
  end
end
