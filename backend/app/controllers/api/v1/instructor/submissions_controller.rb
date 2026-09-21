module Api
  module V1
    module Instructor
      class SubmissionsController < BaseController
        before_action :set_submission, only: :grade

        def pending
          authorize AssignmentSubmission, :pending?
          submissions = policy_scope(AssignmentSubmission)
                        .where(status: :submitted)
                        .left_joins(:grade)
                        .where(grades: { id: nil })
                        .includes(:assignment, enrollment: :user, assignment: :course)
                        .order(submitted_at: :desc)
          records, meta = paginate(submissions)
          render_data(
            serialize_collection(records, serializer: Api::V1::InstructorPendingSubmissionSerializer),
            meta: meta
          )
        end

        def grade
          authorize @submission, :grade?
          result = Assignments::GradeSubmission.new(
            submission: @submission,
            grader: current_user,
            points: grade_params[:points],
            feedback: grade_params[:feedback]
          ).call
          return render_service_failure(result) if result.failure?

          render_data(serialize(result.data, serializer: Api::V1::AssignmentSubmissionSerializer))
        end

        private

        def set_submission
          @submission = AssignmentSubmission.includes(:assignment, :grade, enrollment: :user).find_by_uuid!(params[:uuid])
        end

        def grade_params
          params.require(:grade).permit(:points, :feedback)
        end
      end
    end
  end
end
