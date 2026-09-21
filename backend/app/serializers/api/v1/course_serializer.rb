module Api
  module V1
    class CourseSerializer < ApplicationSerializer
      attributes :uuid, :title, :slug, :description, :short_description,
                 :status, :level, :duration_minutes, :published_at

      attribute :created_by_uuid do |course|
        course.created_by.uuid
      end

      attribute :category_uuids do |course|
        course.categories.map(&:uuid)
      end

      attribute :instructor_uuids do |course|
        course.instructors.map(&:uuid)
      end

      attribute :average_rating do |course|
        course.average_rating
      end

      attribute :review_count do |course|
        course.review_count
      end
    end
  end
end
