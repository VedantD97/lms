module Enrollments
  class CreateEnrollment
    def initialize(user:, course:)
      @user = user
      @course = course
    end

    def call
      enrollment = Enrollment.new(
        user: user,
        course: course,
        enrolled_at: Time.current,
        status: :active
      )

      unless enrollment.valid?
        return ServiceResult::Base.failure(
          errors: validation_errors(enrollment),
          error_code: "validation_error"
        )
      end

      ActiveRecord::Base.transaction do
        enrollment.save!
        initialize_lesson_progress(enrollment)
        Progress::RecalculateCourseProgress.new(enrollment: enrollment).call
      end

      ServiceResult::Base.success(enrollment.reload)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult::Base.failure(
        errors: validation_errors(e.record),
        error_code: "validation_error"
      )
    end

    private

    attr_reader :user, :course

    def initialize_lesson_progress(enrollment)
      enrollment.course.published_lessons.find_each do |lesson|
        enrollment.lesson_progresses.create!(lesson: lesson, status: :not_started)
      end
    end

    def validation_errors(record)
      record.errors.map do |error|
        { field: error.attribute.to_s, message: error.full_message }
      end
    end
  end
end
