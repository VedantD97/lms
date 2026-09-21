module Api
  module V1
    class LessonDetailSerializer < ApplicationSerializer
      attributes :uuid, :title, :content, :content_type, :duration_seconds,
                 :position, :is_preview, :status

      attribute :resources do |lesson|
        lesson.lesson_resources.ordered.map do |resource|
          JSON.parse(Api::V1::LessonResourceSerializer.render(resource))
        end
      end
    end
  end
end
