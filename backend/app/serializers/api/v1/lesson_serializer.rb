module Api
  module V1
    class LessonSerializer < ApplicationSerializer
      attributes :uuid, :title, :content, :content_type, :duration_seconds,
                 :position, :is_preview, :status, :required_for_completion

      attribute :module_uuid do |lesson|
        lesson.course_module.uuid
      end
    end
  end
end
