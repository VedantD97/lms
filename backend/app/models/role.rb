class Role < ApplicationRecord
  NAMES = %w[super_admin admin instructor student].freeze

  PRIVILEGE_ORDER = {
    "super_admin" => 0,
    "admin" => 1,
    "instructor" => 2,
    "student" => 3
  }.freeze

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  validates :name, presence: true, uniqueness: { case_sensitive: false },
                   inclusion: { in: NAMES }

  scope :ordered_by_privilege, -> {
    order(Arel.sql("CASE name #{PRIVILEGE_ORDER.map { |name, order| "WHEN '#{name}' THEN #{order}" }.join(' ')} END"))
  }

  def self.[](name)
    find_by!(name: name.to_s)
  end
end
