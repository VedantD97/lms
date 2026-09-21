module Api
  module V1
    class StudentLessonSerializer < ApplicationSerializer
      attributes :uuid, :title, :content, :content_type, :duration_seconds,
                 :position, :is_preview, :status

      attribute :module_uuid do |lesson|
        lesson.course_module.uuid
      end

      attribute :module_title do |lesson|
        lesson.course_module.title
      end

      attribute :course_uuid do |lesson|
        lesson.course_module.course.uuid
      end
    end
  end
end
