module Api
  module V1
    class LessonResourceSerializer < ApplicationSerializer
      attributes :uuid, :resource_type, :title, :external_url, :position, :metadata

      attribute :lesson_uuid do |resource|
        resource.lesson.uuid
      end

      attribute :file_url do |resource|
        next unless resource.file.attached?

        Rails.application.routes.url_helpers.rails_blob_path(resource.file, only_path: true)
      end
    end
  end
end
