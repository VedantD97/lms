module Progress
  class UpdateLessonProgress
    COMPLETION_THRESHOLD = 90

    def initialize(enrollment:, lesson:, progress_percent:, last_position_seconds: nil)
      @enrollment = enrollment
      @lesson = lesson
      @progress_percent = progress_percent.to_f
      @last_position_seconds = last_position_seconds
    end

    def call
      lesson_progress = enrollment.lesson_progresses.find_by!(lesson: lesson)

      lesson_progress.progress_percent = progress_percent.clamp(0, 100)
      lesson_progress.last_position_seconds = last_position_seconds if last_position_seconds.present?
      lesson_progress.status = :in_progress if lesson_progress.not_started?
      lesson_progress.started_at ||= Time.current

      if lesson_progress.progress_percent >= COMPLETION_THRESHOLD
        lesson_progress.status = :completed
        lesson_progress.completed_at = Time.current
      end

      lesson_progress.save!
      Progress::RecalculateCourseProgress.new(enrollment: enrollment.reload).call

      ServiceResult::Base.success(lesson_progress.reload)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult::Base.failure(
        errors: e.record.errors.map { |error| { field: error.attribute.to_s, message: error.full_message } },
        error_code: "validation_error"
      )
    end

    private

    attr_reader :enrollment, :lesson, :progress_percent, :last_position_seconds
  end
end
