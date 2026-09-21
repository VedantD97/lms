module Courses
  class PublishCourse
    def initialize(course:)
      @course = course
    end

    def call
      unless course.draft? || course.archived?
        return ServiceResult::Base.failure(
          errors: [ { field: "status", message: "Course cannot be published from its current status" } ],
          error_code: "invalid_state"
        )
      end

      course.publish!
      ServiceResult::Base.success(course.reload)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult::Base.failure(
        errors: e.record.errors.map { |error| { field: error.attribute.to_s, message: error.full_message } },
        error_code: "validation_error"
      )
    end

    private

    attr_reader :course
  end
end
