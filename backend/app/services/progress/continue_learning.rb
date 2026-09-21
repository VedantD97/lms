module Progress
  class ContinueLearning
    def initialize(enrollment:)
      @enrollment = enrollment
    end

    def call
      next_progress = enrollment.lesson_progresses
                                 .includes(lesson: :course_module)
                                 .joins(lesson: :course_module)
                                 .merge(CourseModule.published)
                                 .where(lessons: { status: Lesson.statuses[:published] })
                                 .where.not(status: LessonProgress.statuses[:completed])
                                 .order("course_modules.position ASC, lessons.position ASC")
                                 .first

      return ServiceResult::Base.success(nil) if next_progress.nil?

      lesson = next_progress.lesson
      ServiceResult::Base.success(
        lesson_uuid: lesson.uuid,
        lesson_title: lesson.title,
        module_title: lesson.course_module.title,
        content_type: lesson.content_type,
        progress_percent: next_progress.progress_percent,
        last_position_seconds: next_progress.last_position_seconds,
        status: next_progress.status
      )
    end

    private

    attr_reader :enrollment
  end
end
