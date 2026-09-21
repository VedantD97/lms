class LessonResource < ApplicationRecord
  include Identifiable
  include Orderable

  enum :resource_type, { video: 0, pdf: 1, document: 2, image: 3, link: 4 }, validate: true

  belongs_to :lesson

  has_one_attached :file

  validates :title, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :external_url, presence: true, if: :link?
  validate :file_or_url_present
  validate :validate_uploaded_file, if: -> { file.attached? && !link? }

  MAX_UPLOAD_SIZE = 50.megabytes
  ALLOWED_CONTENT_TYPES = {
    video: %w[video/mp4 video/webm video/quicktime],
    pdf: %w[application/pdf],
    document: %w[
      application/pdf
      application/msword
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
      text/plain
    ],
    image: %w[image/jpeg image/png image/gif image/webp]
  }.freeze

  private

  def validate_uploaded_file
    if file.blob.byte_size > MAX_UPLOAD_SIZE
      errors.add(:file, "must be smaller than 50 MB")
    end

    allowed = ALLOWED_CONTENT_TYPES[resource_type.to_sym]
    return if allowed.blank?

    content_type = file.blob.content_type.to_s
    return if allowed.include?(content_type)

    errors.add(:file, "must be a valid #{resource_type} file type")
  end

  def file_or_url_present
    return if link? && external_url.present?
    return if !link? && file.attached?

    errors.add(:base, "must have an attached file or external URL")
  end
end
