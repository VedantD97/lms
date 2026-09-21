module Api
  module V1
    module Admin
      class QuizzesController < BaseController
        before_action :set_quiz, only: %i[show statistics]

        def index
          quizzes = policy_scope(Quiz).includes(:course, :questions).order(created_at: :desc)
          records, meta = paginate(quizzes)
          authorize Quiz
          render_data(serialize_collection(records, serializer: Api::V1::QuizSerializer), meta: meta)
        end

        def show
          authorize @quiz
          render_data(serialize(@quiz, serializer: Api::V1::QuizDetailSerializer))
        end

        def statistics
          authorize @quiz, :statistics?
          attempts = @quiz.quiz_attempts.where(status: :submitted)
          stats = build_statistics(attempts)
          render_data(serialize(@quiz, serializer: Api::V1::QuizSerializer).merge(stats))
        end

        private

        def set_quiz
          @quiz = Quiz.find_by_uuid!(params[:uuid])
        end

        def build_statistics(attempts)
          completed = attempts.count
          unique_students = attempts.distinct.count(:enrollment_id)
          average_score = completed.positive? ? attempts.average(:score).to_f.round(2) : 0
          average_percentage = completed.positive? ? attempts.average(:percentage).to_f.round(2) : 0
          pass_rate = completed.positive? ? ((attempts.where(passed: true).count.to_f / completed) * 100).round(2) : 0

          {
            total_attempts: @quiz.quiz_attempts.count,
            completed_attempts: completed,
            average_score: average_score,
            average_percentage: average_percentage,
            pass_rate: pass_rate,
            unique_students: unique_students
          }
        end
      end
    end
  end
end
