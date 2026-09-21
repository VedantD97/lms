module Api
  module V1
    module Student
      class CoursesController < BaseController
        include Api::CourseFiltering
        include Api::Cacheable

        before_action :set_course, only: %i[show enroll]

        def index
          authorize Course
          cache_params = filter_params.to_h.compact
          payload = fetch_cached(Cache::Keys.student_catalog(cache_params), expires_in: 2.minutes) do
            courses = filtered_courses(Course.catalog).includes(:categories).recently_published
            records, meta = paginate(courses)
            {
              data: serialize_collection(records, serializer: Api::V1::CourseSerializer),
              meta: meta
            }
          end
          render_data(payload[:data], meta: payload[:meta])
        end

        def show
          authorize @course
          render_data(
            JSON.parse(
              Api::V1::StudentCourseDetailSerializer.render(
                @course,
                params: { current_user: current_user }
              )
            )
          )
        end

        def enroll
          authorize Enrollment.new(user: current_user, course: @course), :create?

          result = Enrollments::CreateEnrollment.new(user: current_user, course: @course).call
          return render_service_failure(result) if result.failure?

          render_data(serialize(result.data, serializer: Api::V1::EnrollmentSerializer), status: :created)
        end

        private

        def set_course
          @course = Course.find_by_uuid!(params[:uuid])
        end
      end
    end
  end
end
