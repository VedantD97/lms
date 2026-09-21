module Api
  module V1
    module Admin
      class EnrollmentsController < BaseController
        before_action :set_enrollment, only: %i[show destroy]

        def index
          enrollments = policy_scope(Enrollment).includes(:user, :course).order(enrolled_at: :desc)
          records, meta = paginate(enrollments)
          authorize Enrollment
          render_data(serialize_collection(records, serializer: Api::V1::EnrollmentSerializer), meta: meta)
        end

        def show
          authorize @enrollment
          render_data(serialize(@enrollment, serializer: Api::V1::EnrollmentSerializer))
        end

        def create
          user = User.find_by_uuid!(params.require(:user_uuid))
          course = Course.find_by_uuid!(params.require(:course_uuid))
          authorize Enrollment.new(user: user, course: course)

          result = Enrollments::CreateEnrollment.new(user: user, course: course).call
          return render_service_failure(result) if result.failure?

          render_data(serialize(result.data, serializer: Api::V1::EnrollmentSerializer), status: :created)
        end

        def destroy
          authorize @enrollment
          enrollment_snapshot = {
            user_uuid: @enrollment.user.uuid,
            course_uuid: @enrollment.course.uuid,
            status: @enrollment.status
          }
          @enrollment.update!(status: :dropped)
          record_audit!(action: "enrollment.dropped", auditable: @enrollment, changes: enrollment_snapshot)
          head :no_content
        end

        private

        def set_enrollment
          @enrollment = Enrollment.find_by_uuid!(params[:uuid])
        end
      end
    end
  end
end
