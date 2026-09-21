class User < ApplicationRecord
  include Identifiable

  has_secure_password

  enum :status, { active: 0, inactive: 1, suspended: 2 }, validate: true

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :refresh_tokens, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy
  has_many :created_courses, class_name: "Course", foreign_key: :created_by_id, dependent: :nullify
  has_many :course_instructors, dependent: :destroy
  has_many :instructed_courses, through: :course_instructors, source: :course
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :notifications, dependent: :destroy
  has_many :authored_announcements, class_name: "Announcement", foreign_key: :author_id, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :audit_logs, foreign_key: :actor_id, dependent: :nullify, inverse_of: :actor

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :uuid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, presence: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  scope :with_roles, -> { includes(:roles) }

  def role_names
    roles.pluck(:name)
  end

  def super_admin?
    role_names.include?("super_admin")
  end

  def admin?
    role_names.include?("admin")
  end

  def instructor?
    role_names.include?("instructor")
  end

  def student?
    role_names.include?("student")
  end

  def admin_or_above?
    super_admin? || admin?
  end

  def highest_role
    roles.min_by { |role| Role::PRIVILEGE_ORDER.fetch(role.name, 99) }&.name
  end

  def assign_role!(role_name)
    role = Role.find_by!(name: role_name)
    roles << role unless roles.exists?(role.id)
  end

  def authenticate_active_for_password?(password)
    active? && authenticate(password)
  end
end
