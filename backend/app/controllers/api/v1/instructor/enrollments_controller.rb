module Api
  module V1
    module Instructor
      class EnrollmentsController < BaseController
        before_action :set_course, only: :index
        before_action :set_enrollment, only: :progress

        def index
          authorize @course, :view_enrollments?
          enrollments = @course.enrollments.includes(:user).order(enrolled_at: :desc)
          records, meta = paginate(enrollments)
          render_data(
            serialize_collection(records, serializer: Api::V1::InstructorEnrollmentSerializer),
            meta: meta
          )
        end

        def progress
          authorize @enrollment, :progress?
          render_data(
            serialize(@enrollment, serializer: Api::V1::InstructorEnrollmentSerializer).merge(
              progress_summary: Progress::CourseCompletion.new(enrollment: @enrollment).summary
            )
          )
        end

        private

        def set_course
          @course = Course.find_by_uuid!(params[:course_uuid] || params[:uuid])
        end

        def set_enrollment
          @enrollment = Enrollment.includes(:user, :course).find_by_uuid!(params[:uuid])
        end
      end
    end
  end
end
