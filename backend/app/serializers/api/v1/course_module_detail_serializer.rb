module Api
  module V1
    class CourseModuleDetailSerializer < ApplicationSerializer
      attributes :uuid, :title, :description, :position, :status

      attribute :lessons do |course_module|
        course_module.lessons.ordered.map do |lesson|
          JSON.parse(Api::V1::LessonDetailSerializer.render(lesson))
        end
      end
    end
  end
end
