module Courses
  class UnpublishCourse
    def initialize(course:)
      @course = course
    end

    def call
      unless course.published?
        return ServiceResult::Base.failure(
          errors: [ { field: "status", message: "Only published courses can be unpublished" } ],
          error_code: "invalid_state"
        )
      end

      course.update!(status: :draft, published_at: nil)
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
