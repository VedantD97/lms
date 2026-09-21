class QuestionOptionPolicy < ApplicationPolicy
  def create?
    can_manage_question?
  end

  def update?
    can_manage_question?
  end

  def destroy?
    can_manage_question?
  end

  private

  def can_manage_question?
    admin_or_above? || record.question.quiz.course.instructor?(user)
  end
end
