module Courses
  class ArchiveCourse
    def initialize(course:)
      @course = course
    end

    def call
      course.update!(status: :archived)
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
