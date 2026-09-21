class QuestionPolicy < ApplicationPolicy
  def index?
    can_manage_quiz?
  end

  def show?
    can_manage_quiz? || can_view_as_student?
  end

  def create?
    can_manage_quiz?
  end

  def update?
    can_manage_quiz?
  end

  def destroy?
    can_manage_quiz?
  end

  def reorder?
    can_manage_quiz?
  end

  private

  def can_manage_quiz?
    admin_or_above? || record.quiz.course.instructor?(user)
  end

  def can_view_as_student?
    QuizPolicy.new(user, record.quiz).show?
  end
end
