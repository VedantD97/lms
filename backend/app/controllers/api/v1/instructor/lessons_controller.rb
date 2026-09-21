module Api
  module V1
    module Instructor
      class LessonsController < BaseController
        before_action :set_module, only: %i[index create reorder]
        before_action :set_lesson, only: %i[update destroy]

        def index
          authorize @course_module, :show?
          lessons = @course_module.lessons.ordered
          render_data(serialize_collection(lessons, serializer: Api::V1::LessonSerializer))
        end

        def create
          lesson = @course_module.lessons.build(lesson_params)
          authorize lesson

          if lesson.save
            render_data(serialize(lesson, serializer: Api::V1::LessonSerializer), status: :created)
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(lesson))
          end
        end

        def update
          authorize @lesson

          if @lesson.update(lesson_params)
            render_data(serialize(@lesson, serializer: Api::V1::LessonSerializer))
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(@lesson))
          end
        end

        def destroy
          authorize @lesson
          @lesson.destroy!
          head :no_content
        end

        def reorder
          authorize @course_module, :update?
          lessons = @course_module.lessons.ordered
          result = Courses::ReorderRecords.new(
            records: lessons,
            ordered_uuids: params.require(:ordered_uuids)
          ).call

          return render_service_failure(result) if result.failure?

          render_data(serialize_collection(result.data, serializer: Api::V1::LessonSerializer))
        end

        private

        def set_module
          @course_module = CourseModule.find_by_uuid!(params[:module_uuid] || params[:uuid])
        end

        def set_lesson
          @lesson = Lesson.find_by_uuid!(params[:uuid])
        end

        def lesson_params
          params.require(:lesson).permit(
            :title, :content, :content_type, :duration_seconds, :position, :is_preview, :status,
            :required_for_completion
          )
        end
      end
    end
  end
end
