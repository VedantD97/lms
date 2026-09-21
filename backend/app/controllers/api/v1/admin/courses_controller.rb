module Api
  module V1
    module Admin
      class CoursesController < BaseController
        include Api::CourseFiltering

        before_action :set_course, only: %i[
          show update destroy assign_instructor remove_instructor publish unpublish archive
        ]

        def index
          courses = filtered_courses(policy_scope(Course))
                    .includes(:categories, :instructors, :created_by)
                    .order(created_at: :desc)
          records, meta = paginate(courses)
          authorize Course
          render_data(serialize_collection(records, serializer: Api::V1::CourseSerializer), meta: meta)
        end

        def show
          authorize @course
          render_data(serialize(@course, serializer: Api::V1::CourseDetailSerializer))
        end

        def create
          course = Course.new(course_params.merge(created_by: current_user))
          authorize course

          ActiveRecord::Base.transaction do
            course.save!
            sync_categories(course)
          end

          render_data(serialize(course.reload, serializer: Api::V1::CourseDetailSerializer), status: :created)
        rescue ActiveRecord::RecordInvalid => e
          render_record_invalid(e)
        end

        def update
          authorize @course

          ActiveRecord::Base.transaction do
            @course.update!(course_params)
            sync_categories(@course) if params[:course].key?(:category_uuids)
          end

          render_data(serialize(@course.reload, serializer: Api::V1::CourseDetailSerializer))
        rescue ActiveRecord::RecordInvalid => e
          render_record_invalid(e)
        end

        def destroy
          authorize @course
          result = Courses::ArchiveCourse.new(course: @course).call
          return render_service_failure(result) if result.failure?

          head :no_content
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

        def archive
          authorize @course, :archive?
          result = Courses::ArchiveCourse.new(course: @course).call
          return render_service_failure(result) if result.failure?

          render_data(serialize(result.data, serializer: Api::V1::CourseDetailSerializer))
        end

        def assign_instructor
          authorize @course, :assign_instructor?

          instructor = User.find_by_uuid!(params.require(:user_uuid))
          assignment = @course.course_instructors.find_or_initialize_by(user: instructor)
          assignment.role = params.fetch(:role, "lead")
          assignment.save!

          render_data(serialize(assignment.course.reload, serializer: Api::V1::CourseDetailSerializer))
        rescue ActiveRecord::RecordInvalid => e
          render_record_invalid(e)
        end

        def remove_instructor
          authorize @course, :remove_instructor?

          instructor = User.find_by_uuid!(params[:user_uuid])
          assignment = @course.course_instructors.find_by!(user: instructor)
          assignment.destroy!

          head :no_content
        end

        private

        def set_course
          @course = Course.find_by_uuid!(params[:uuid])
        end

        def course_params
          params.require(:course).permit(
            :title, :slug, :description, :short_description, :status, :level, :duration_minutes, :published_at
          )
        end

        def sync_categories(course)
          uuids = params.dig(:course, :category_uuids)
          return if uuids.nil?

          categories = Category.where(uuid: uuids)
          course.categories = categories
        end
      end
    end
  end
end
