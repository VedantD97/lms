module Api
  module V1
    class CourseModuleSerializer < ApplicationSerializer
      attributes :uuid, :title, :description, :position, :status

      attribute :course_uuid do |course_module|
        course_module.course.uuid
      end
    end
  end
end
