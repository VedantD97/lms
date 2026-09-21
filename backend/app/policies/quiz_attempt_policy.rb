class QuizAttemptPolicy < ApplicationPolicy
  def show?
    owner? || can_manage_quiz?
  end

  def save_responses?
    owner? && record.editable?
  end

  def submit?
    owner? && (record.in_progress? || record.editable?)
  end

  def results?
    owner? || can_manage_quiz?
  end

  class Scope < Scope
    def resolve
      if user.admin_or_above?
        scope.all
      elsif user.instructor?
        scope.joins(quiz: :course).merge(Course.where(id: user.instructed_courses.select(:id)))
      elsif user.student?
        scope.joins(:enrollment).merge(Enrollment.for_user(user))
      else
        scope.none
      end
    end
  end

  private

  def owner?
    record.enrollment.user_id == user.id
  end

  def can_manage_quiz?
    admin_or_above? || record.quiz.course.instructor?(user)
  end
end
