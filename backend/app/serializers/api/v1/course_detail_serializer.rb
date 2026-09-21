module Api
  module V1
    class CourseDetailSerializer < ApplicationSerializer
      attributes :uuid, :title, :slug, :description, :short_description,
                 :status, :level, :duration_minutes, :published_at

      attribute :created_by_uuid do |course|
        course.created_by.uuid
      end

      attribute :categories do |course|
        course.categories.map do |category|
          JSON.parse(Api::V1::CategorySerializer.render(category))
        end
      end

      attribute :instructor_uuids do |course|
        course.instructors.map(&:uuid)
      end

      attribute :modules do |course|
        course.course_modules.ordered.map do |course_module|
          JSON.parse(Api::V1::CourseModuleDetailSerializer.render(course_module))
        end
      end
    end
  end
end
