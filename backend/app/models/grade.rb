class Grade < ApplicationRecord
  include Identifiable

  belongs_to :gradable, polymorphic: true
  belongs_to :graded_by, class_name: "User"

  validates :points, numericality: { greater_than_or_equal_to: 0 }
  validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
