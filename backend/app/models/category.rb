class Category < ApplicationRecord
  include Identifiable
  include Sluggable
  include Orderable

  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: :parent_id, dependent: :nullify
  has_many :course_categories, dependent: :destroy
  has_many :courses, through: :course_categories

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :parent_cannot_be_self

  scope :roots, -> { where(parent_id: nil) }

  private

  def parent_cannot_be_self
    return if parent_id.blank? || parent_id != id

    errors.add(:parent_id, "cannot be the category itself")
  end
end
