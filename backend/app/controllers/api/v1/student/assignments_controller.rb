module Api
  module V1
    module Student
      class AssignmentsController < BaseController
        before_action :set_enrollment
        before_action :set_assignment, only: %i[show submit]

        def index
          authorize @enrollment, :show?
          assignments = policy_scope(Assignment)
                        .where(course_id: @enrollment.course_id)
                        .published
                        .order(:due_at, :title)

          data = assignments.map do |assignment|
            JSON.parse(
              Api::V1::StudentAssignmentSerializer.render(
                assignment,
                params: student_assignment_params(assignment)
              )
            )
          end

          render_data(data)
        end

        def show
          authorize @assignment
          render_data(
            JSON.parse(
              Api::V1::StudentAssignmentSerializer.render(
                @assignment,
                params: student_assignment_params(@assignment)
              )
            )
          )
        end

        def submit
          authorize @assignment, :submit?
          result = Assignments::SubmitSubmission.new(
            enrollment: @enrollment,
            assignment: @assignment,
            body: submission_params[:body]
          ).call
          return render_service_failure(result) if result.failure?

          render_data(
            JSON.parse(Api::V1::StudentAssignmentSubmissionSerializer.render(result.data)),
            status: :created
          )
        end

        private

        def set_enrollment
          @enrollment = Enrollment.find_by_uuid!(params[:enrollment_uuid] || params[:uuid])
          authorize @enrollment, :show?
        end

        def set_assignment
          @assignment = Assignment.find_by_uuid!(params[:assignment_uuid])
        end

        def submission_params
          params.require(:submission).permit(:body)
        end

        def student_assignment_params(assignment)
          submission = assignment.assignment_submissions.find_by(enrollment: @enrollment)

          {
            submission_status: submission&.status,
            submitted_at: submission&.submitted_at,
            passed: submission&.passed? || false,
            grade_percentage: submission&.grade&.percentage,
            submission_uuid: submission&.uuid
          }
        end
      end
    end
  end
end
