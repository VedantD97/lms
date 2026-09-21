module Assignments
  class SubmitSubmission
    def initialize(enrollment:, assignment:, body:)
      @enrollment = enrollment
      @assignment = assignment
      @body = body.to_s.strip
    end

    def call
      return failure("Assignment is not published", "invalid_state") unless assignment.published?
      return failure("You are not enrolled in this course", "forbidden") unless enrollment.course_id == assignment.course_id
      return failure("Submission body is required", "validation_error") if body.blank?
      return failure("Assignment is past due", "invalid_state") if assignment.past_due? && !assignment.allow_late?

      submission = AssignmentSubmission.find_or_initialize_by(assignment: assignment, enrollment: enrollment)

      if submission.graded?
        if assignment.allow_resubmit && !submission.passed?
          submission.grade&.destroy!
          submission.status = :submitted
        else
          return failure("Submission cannot be updated", "invalid_state")
        end
      elsif submission.submitted?
        return failure("Submission is awaiting grading", "invalid_state") unless assignment.allow_resubmit
      end

      submission.assign_attributes(
        body: body,
        submitted_at: Time.current,
        status: :submitted,
        late: assignment.past_due?
      )
      submission.save!

      ServiceResult::Base.success(submission.reload)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult::Base.failure(
        errors: e.record.errors.map { |err| { field: err.attribute.to_s, message: err.full_message } },
        error_code: "validation_error"
      )
    end

    private

    attr_reader :enrollment, :assignment, :body

    def failure(message, code)
      ServiceResult::Base.failure(errors: [ { field: "base", message: message } ], error_code: code)
    end
  end
end
