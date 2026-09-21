module Api
  module V1
    module Instructor
      class ModulesController < BaseController
        before_action :set_course, only: %i[index create reorder]
        before_action :set_module, only: %i[update destroy]

        def index
          authorize @course, :show?
          modules = @course.course_modules.ordered
          render_data(serialize_collection(modules, serializer: Api::V1::CourseModuleSerializer))
        end

        def create
          course_module = @course.course_modules.build(module_params)
          authorize course_module

          if course_module.save
            render_data(serialize(course_module, serializer: Api::V1::CourseModuleSerializer), status: :created)
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(course_module))
          end
        end

        def update
          authorize @course_module

          if @course_module.update(module_params)
            render_data(serialize(@course_module, serializer: Api::V1::CourseModuleSerializer))
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(@course_module))
          end
        end

        def destroy
          authorize @course_module
          @course_module.destroy!
          head :no_content
        end

        def reorder
          authorize @course, :update?
          modules = @course.course_modules.ordered
          result = Courses::ReorderRecords.new(
            records: modules,
            ordered_uuids: params.require(:ordered_uuids)
          ).call

          return render_service_failure(result) if result.failure?

          render_data(serialize_collection(result.data, serializer: Api::V1::CourseModuleSerializer))
        end

        private

        def set_course
          @course = Course.find_by_uuid!(params[:course_uuid] || params[:uuid])
        end

        def set_module
          @course_module = CourseModule.find_by_uuid!(params[:uuid])
        end

        def module_params
          params.require(:module).permit(:title, :description, :position, :status)
        end
      end
    end
  end
end
