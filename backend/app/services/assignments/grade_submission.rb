module Assignments
  class GradeSubmission
    def initialize(submission:, grader:, points:, feedback: nil)
      @submission = submission
      @grader = grader
      @points = points.to_f
      @feedback = feedback
    end

    def call
      return failure("Submission has not been submitted", "invalid_state") unless submission.submitted? || submission.graded?
      return failure("Points cannot exceed max points", "validation_error") if points > assignment.max_points.to_f
      return failure("Points cannot be negative", "validation_error") if points.negative?

      percentage = (points / assignment.max_points.to_f * 100).round(2)
      passed = percentage >= assignment.passing_score.to_f

      ActiveRecord::Base.transaction do
        grade = submission.grade || submission.build_grade
        grade.update!(
          points: points,
          percentage: percentage,
          passed: passed,
          feedback: feedback,
          graded_by: grader,
          graded_at: Time.current
        )
        submission.update!(status: :graded)
      end

      Progress::RecalculateCourseProgress.new(enrollment: submission.enrollment.reload).call

      notify_student(submission, percentage, passed)

      ServiceResult::Base.success(submission.reload)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult::Base.failure(
        errors: e.record.errors.map { |err| { field: err.attribute.to_s, message: err.full_message } },
        error_code: "validation_error"
      )
    end

    private

    attr_reader :submission, :grader, :points, :feedback

    def assignment
      submission.assignment
    end

    def failure(message, code)
      ServiceResult::Base.failure(errors: [ { field: "base", message: message } ], error_code: code)
    end

    def notify_student(submission, percentage, passed)
      Notifications::CreateNotification.new(
        user: submission.enrollment.user,
        notification_type: :assignment_graded,
        payload: {
          title: "Assignment graded",
          body: "Your submission for #{assignment.title} was graded: #{percentage}%#{passed ? ' (passed)' : ''}",
          course_uuid: assignment.course.uuid,
          course_title: assignment.course.title,
          assignment_uuid: assignment.uuid,
          enrollment_uuid: submission.enrollment.uuid,
          percentage: percentage,
          passed: passed
        }
      ).call
    end
  end
end
