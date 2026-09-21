module Api
  module V1
    module Student
      class EnrollmentsController < BaseController
        before_action :set_enrollment, only: %i[show lesson_progress update_lesson_progress complete_lesson]

        def index
          enrollments = policy_scope(Enrollment).includes(course: :categories).order(enrolled_at: :desc)
          records, meta = paginate(enrollments)
          authorize Enrollment
          render_data(serialize_collection(records, serializer: Api::V1::StudentEnrollmentSerializer), meta: meta)
        end

        def show
          authorize @enrollment
          continue = Progress::ContinueLearning.new(enrollment: @enrollment).call.data
          render_data(
            serialize(@enrollment, serializer: Api::V1::StudentEnrollmentSerializer).merge(
              "lesson_progress" => serialize_collection(
                @enrollment.lesson_progresses.includes(lesson: :course_module),
                serializer: Api::V1::LessonProgressSerializer
              ),
              "continue_learning" => continue
            )
          )
        end

        def lesson_progress
          authorize @enrollment, :show?
          lesson = Lesson.includes(:course_module).find_by_uuid!(params[:lesson_uuid])
          lesson_progress = @enrollment.lesson_progresses.find_by!(lesson: lesson)
          authorize lesson, :show?

          render_data(
            serialize(lesson, serializer: Api::V1::StudentLessonSerializer).merge(
              "progress" => serialize(lesson_progress, serializer: Api::V1::LessonProgressSerializer),
              "resources" => serialize_collection(
                lesson.lesson_resources.ordered,
                serializer: Api::V1::StudentLessonResourceSerializer
              )
            )
          )
        end

        def update_lesson_progress
          authorize @enrollment, :show?
          lesson = Lesson.find_by_uuid!(params[:lesson_uuid])
          lesson_progress = @enrollment.lesson_progresses.find_by!(lesson: lesson)
          authorize lesson_progress, :update?

          result = Progress::UpdateLessonProgress.new(
            enrollment: @enrollment,
            lesson: lesson,
            progress_percent: progress_params[:progress_percent],
            last_position_seconds: progress_params[:last_position_seconds]
          ).call

          return render_service_failure(result) if result.failure?

          render_data(serialize(result.data, serializer: Api::V1::LessonProgressSerializer))
        end

        def complete_lesson
          authorize @enrollment, :show?
          lesson = Lesson.find_by_uuid!(params[:lesson_uuid])
          lesson_progress = @enrollment.lesson_progresses.find_by!(lesson: lesson)
          authorize lesson_progress, :complete?

          result = Progress::MarkLessonComplete.new(enrollment: @enrollment, lesson: lesson).call
          return render_service_failure(result) if result.failure?

          render_data(serialize(result.data, serializer: Api::V1::LessonProgressSerializer))
        end

        private

        def set_enrollment
          @enrollment = Enrollment.find_by_uuid!(params[:uuid])
        end

        def progress_params
          params.require(:progress).permit(:progress_percent, :last_position_seconds)
        end
      end
    end
  end
end
