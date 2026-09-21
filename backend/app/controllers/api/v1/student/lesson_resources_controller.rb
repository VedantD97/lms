module Api
  module V1
    module Student
      class LessonResourcesController < BaseController
        before_action :set_enrollment
        before_action :set_resource

        def download
          authorize @resource, :download?
          verify_resource_belongs_to_enrollment!

          if @resource.link?
            render_data({ external_url: @resource.external_url, external: true })
            return
          end

          unless @resource.file.attached?
            return render_error(code: "not_found", message: "File not found", status: :not_found)
          end

          send_data @resource.file.download,
                    filename: @resource.file.filename.to_s,
                    type: @resource.file.content_type,
                    disposition: "attachment"
        end

        private

        def set_enrollment
          @enrollment = Enrollment.find_by_uuid!(params[:uuid])
          authorize @enrollment, :show?
        end

        def set_resource
          @resource = LessonResource.find_by_uuid!(params[:resource_uuid])
        end

        def verify_resource_belongs_to_enrollment!
          lesson_course_id = @resource.lesson.course_module.course_id
          return if lesson_course_id == @enrollment.course_id

          raise ActiveRecord::RecordNotFound
        end

        def render_error(code:, message:, status:)
          render json: { error: { code: code, message: message } }, status: status
        end
      end
    end
  end
end
