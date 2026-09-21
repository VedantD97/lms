module Api
  module V1
    module Instructor
      class CoursesController < BaseController
        include Api::CourseFiltering

        before_action :set_course, only: %i[show update publish unpublish]

        def index
          courses = filtered_courses(policy_scope(Course))
                    .includes(:categories, :instructors)
                    .order(created_at: :desc)
          records, meta = paginate(courses)
          authorize Course
          render_data(serialize_collection(records, serializer: Api::V1::CourseSerializer), meta: meta)
        end

        def create
          course = Course.new(course_params.merge(created_by: current_user, status: :draft))
          authorize course

          ActiveRecord::Base.transaction do
            course.save!
            course.course_instructors.create!(user: current_user, role: :lead)
          end

          render_data(serialize(course.reload, serializer: Api::V1::CourseDetailSerializer), status: :created)
        rescue ActiveRecord::RecordInvalid => e
          render_record_invalid(e)
        end

        def show
          authorize @course
          render_data(serialize(@course, serializer: Api::V1::CourseDetailSerializer))
        end

        def update
          authorize @course

          if @course.update(course_params)
            render_data(serialize(@course, serializer: Api::V1::CourseDetailSerializer))
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(@course))
          end
        end

        def publish
          authorize @course, :publish?
          result = Courses::PublishCourse.new(course: @course).call
          return render_service_failure(result) if result.failure?

          render_data(serialize(result.data, serializer: Api::V1::CourseDetailSerializer))
        end

        def unpublish
          authorize @course, :unpublish?
          result = Courses::UnpublishCourse.new(course: @course).call
          return render_service_failure(result) if result.failure?

          render_data(serialize(result.data, serializer: Api::V1::CourseDetailSerializer))
        end

        private

        def set_course
          @course = Course.find_by_uuid!(params[:uuid])
        end

        def course_params
          params.require(:course).permit(
            :title, :slug, :description, :short_description, :level, :duration_minutes
          )
        end
      end
    end
  end
end
