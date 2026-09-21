module Api
  module V1
    module Instructor
      class AssignmentsController < BaseController
        before_action :set_lesson, only: %i[index create]
        before_action :set_course, only: %i[index create]
        before_action :set_assignment, only: %i[show update destroy publish unpublish submissions]

        def index
          assignments = if @lesson
                          @lesson.assignments.order(created_at: :desc)
          else
                          @course.assignments.order(created_at: :desc)
          end
          authorize Assignment
          render_data(serialize_collection(assignments, serializer: Api::V1::AssignmentSerializer))
        end

        def show
          authorize @assignment
          render_data(serialize(@assignment, serializer: Api::V1::AssignmentDetailSerializer))
        end

        def create
          assignment = (@lesson || @course).assignments.build(assignment_params)
          assignment.course = @lesson ? @lesson.course_module.course : @course
          authorize assignment

          if assignment.save
            render_data(serialize(assignment, serializer: Api::V1::AssignmentDetailSerializer), status: :created)
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(assignment))
          end
        end

        def update
          authorize @assignment

          if @assignment.update(assignment_params)
            render_data(serialize(@assignment, serializer: Api::V1::AssignmentDetailSerializer))
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(@assignment))
          end
        end

        def destroy
          authorize @assignment
          @assignment.destroy!
          head :no_content
        end

        def publish
          authorize @assignment, :publish?
          @assignment.update!(status: :published)
          render_data(serialize(@assignment, serializer: Api::V1::AssignmentSerializer))
        end

        def unpublish
          authorize @assignment, :unpublish?
          @assignment.update!(status: :draft)
          render_data(serialize(@assignment, serializer: Api::V1::AssignmentSerializer))
        end

        def submissions
          authorize @assignment, :view_submissions?
          submissions = @assignment.assignment_submissions.includes(:enrollment, :grade, enrollment: :user).order(submitted_at: :desc)
          records, meta = paginate(submissions)
          render_data(serialize_collection(records, serializer: Api::V1::AssignmentSubmissionSerializer), meta: meta)
        end

        private

        def set_lesson
          lesson_uuid = params[:lesson_uuid]
          return if lesson_uuid.blank?

          @lesson = Lesson.find_by_uuid!(lesson_uuid)
        end

        def set_course
          @course = if @lesson
                      @lesson.course_module.course
          else
                      Course.find_by_uuid!(params[:course_uuid])
          end
        end

        def set_assignment
          @assignment = Assignment.find_by_uuid!(params[:uuid])
        end

        def assignment_params
          params.require(:assignment).permit(
            :title, :description, :due_at, :max_points, :passing_score,
            :allow_late, :allow_resubmit, :required_for_completion, :status
          )
        end
      end
    end
  end
end
