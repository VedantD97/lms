module Progress
  class MarkLessonComplete
    def initialize(enrollment:, lesson:)
      @enrollment = enrollment
      @lesson = lesson
    end

    def call
      unless lesson_belongs_to_course?
        return ServiceResult::Base.failure(
          errors: [ { field: "lesson", message: "must belong to the enrolled course" } ],
          error_code: "validation_error"
        )
      end

      lesson_progress = enrollment.lesson_progresses.find_or_create_by!(lesson: lesson) do |record|
        record.status = :not_started
      end

      lesson_progress.update!(
        status: :completed,
        progress_percent: 100,
        started_at: lesson_progress.started_at || Time.current,
        completed_at: Time.current
      )

      Progress::RecalculateCourseProgress.new(enrollment: enrollment.reload).call
      ServiceResult::Base.success(lesson_progress.reload)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult::Base.failure(
        errors: e.record.errors.map { |error| { field: error.attribute.to_s, message: error.full_message } },
        error_code: "validation_error"
      )
    end

    private

    attr_reader :enrollment, :lesson

    def lesson_belongs_to_course?
      lesson.course_module.course_id == enrollment.course_id
    end
  end
end
