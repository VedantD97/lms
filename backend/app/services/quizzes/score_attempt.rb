module Quizzes
  class ScoreAttempt
    def initialize(attempt:)
      @attempt = attempt
    end

    def call
      score = 0.to_d
      max_score = attempt.quiz.total_points.to_d

      attempt.quiz_responses.includes(:question).find_each do |response|
        question = response.question
        selected = Array(response.selected_option_uuids)
        correct = question.correct_option_uuids
        is_correct = selected.sort == correct.sort

        points_awarded = is_correct ? question.points : 0
        response.update!(is_correct: is_correct, points_awarded: points_awarded)
        score += points_awarded
      end

      percentage = max_score.positive? ? ((score / max_score) * 100).round(2) : 0
      passed = percentage >= attempt.quiz.passing_score

      ServiceResult::Base.success(
        score: score,
        max_score: max_score,
        percentage: percentage,
        passed: passed
      )
    end

    private

    attr_reader :attempt
  end
end
