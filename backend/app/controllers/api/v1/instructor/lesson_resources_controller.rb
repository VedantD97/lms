module Api
  module V1
    module Instructor
      class LessonResourcesController < BaseController
        before_action :set_lesson, only: %i[create]
        before_action :set_resource, only: %i[destroy]

        def create
          resource = @lesson.lesson_resources.build(resource_params)
          authorize resource

          if params.dig(:resource, :file).present?
            resource.file.attach(params[:resource][:file])
          end

          if resource.save
            render_data(serialize(resource, serializer: Api::V1::LessonResourceSerializer), status: :created)
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(resource))
          end
        end

        def destroy
          authorize @resource
          @resource.destroy!
          head :no_content
        end

        private

        def set_lesson
          @lesson = Lesson.find_by_uuid!(params[:lesson_uuid] || params[:uuid])
        end

        def set_resource
          @resource = LessonResource.find_by_uuid!(params[:uuid])
        end

        def resource_params
          params.require(:resource).permit(:resource_type, :title, :external_url, :position, metadata: {})
        end
      end
    end
  end
end
