module Api
  module V1
    class StudentLessonResourceSerializer < ApplicationSerializer
      attributes :uuid, :resource_type, :title, :external_url, :position, :metadata

      attribute :lesson_uuid do |resource|
        resource.lesson.uuid
      end

      attribute :downloadable do |resource|
        resource.file.attached? || resource.link?
      end
    end
  end
end
