class Course < ApplicationRecord
  include Identifiable
  include Sluggable
  include Publishable
  include CourseSearchable

  enum :status, { draft: 0, published: 1, archived: 2 }, validate: true
  enum :level, { beginner: 0, intermediate: 1, advanced: 2 }, validate: true

  belongs_to :created_by, class_name: "User"
  has_many :course_categories, dependent: :destroy
  has_many :categories, through: :course_categories
  has_many :course_instructors, dependent: :destroy
  has_many :instructors, through: :course_instructors, source: :user
  has_many :course_modules, dependent: :destroy
  has_many :lessons, through: :course_modules
  has_many :quizzes, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :announcements, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user

  has_one_attached :thumbnail

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :duration_minutes, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :catalog, -> { published.where.not(published_at: nil) }
  scope :recently_published, -> { catalog.order(published_at: :desc) }
  scope :archived, -> { where(status: statuses[:archived]) }
  scope :manageable, -> { where.not(status: statuses[:archived]) }

  def instructor?(user)
    course_instructors.exists?(user_id: user.id)
  end

  def published_lessons
    Lesson.published
          .joins(:course_module)
          .where(course_modules: { course_id: id, status: CourseModule.statuses[:published] })
          .order("course_modules.position ASC, lessons.position ASC")
  end

  def required_lessons
    published_lessons.where(required_for_completion: true)
  end

  def required_quizzes
    quizzes.published.available.where(required_for_completion: true)
  end

  def required_assignments
    assignments.published.where(required_for_completion: true)
  end

  def publish!
    update!(status: :published, published_at: Time.current)
  end

  def unpublish!
    update!(status: :draft, published_at: nil)
  end

  def archive!
    update!(status: :archived)
  end

  def average_rating
    reviews.average(:rating)&.to_f&.round(2)
  end

  def review_count
    reviews.count
  end
end
