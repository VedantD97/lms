module Progress
  class CourseCompletion
    def initialize(enrollment:)
      @enrollment = enrollment
    end

    def total_required_items
      required_lesson_ids.size + required_quiz_ids.size + required_assignment_ids.size
    end

    def completed_required_items
      completed_lessons_count + passed_quizzes_count + passed_assignments_count
    end

    def progress_percent
      total = total_required_items
      return 0.0 if total.zero?

      (completed_required_items.to_f / total * 100).round(2)
    end

    def complete?
      total_required_items.positive? && completed_required_items >= total_required_items
    end

    def summary
      {
        total_items: total_required_items,
        completed_items: completed_required_items,
        completed_lessons: completed_lessons_count,
        total_lessons: required_lesson_ids.size,
        passed_quizzes: passed_quizzes_count,
        total_quizzes: required_quiz_ids.size,
        passed_assignments: passed_assignments_count,
        total_assignments: required_assignment_ids.size
      }
    end

    private

    attr_reader :enrollment

    def required_lesson_ids
      @required_lesson_ids ||= enrollment.course.required_lessons.pluck(:id)
    end

    def required_quiz_ids
      @required_quiz_ids ||= enrollment.course.required_quizzes.pluck(:id)
    end

    def required_assignment_ids
      @required_assignment_ids ||= enrollment.course.required_assignments.pluck(:id)
    end

    def completed_lessons_count
      @completed_lessons_count ||= enrollment.lesson_progresses.completed.where(lesson_id: required_lesson_ids).count
    end

    def passed_quizzes_count
      @passed_quizzes_count ||= begin
        return 0 if required_quiz_ids.empty?

        QuizAttempt.where(
          enrollment: enrollment,
          quiz_id: required_quiz_ids,
          status: QuizAttempt.statuses[:submitted],
          passed: true
        ).distinct.count(:quiz_id)
      end
    end

    def passed_assignments_count
      @passed_assignments_count ||= begin
        return 0 if required_assignment_ids.empty?

        AssignmentSubmission.joins(:grade)
                            .where(
                              enrollment: enrollment,
                              assignment_id: required_assignment_ids,
                              status: AssignmentSubmission.statuses[:graded]
                            )
                            .where(grades: { passed: true })
                            .distinct
                            .count(:assignment_id)
      end
    end
  end
end
