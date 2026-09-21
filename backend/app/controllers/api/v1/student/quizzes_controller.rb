module Api
  module V1
    module Student
      class QuizzesController < BaseController
        before_action :set_enrollment
        before_action :set_quiz, only: %i[show start]

        def index
          authorize @enrollment, :show?
          quizzes = policy_scope(Quiz)
                    .where(course_id: @enrollment.course_id)
                    .published
                    .available
                    .includes(:questions)
                    .order(:title)

          data = quizzes.map do |quiz|
            JSON.parse(
              Api::V1::StudentQuizSerializer.render(
                quiz,
                params: student_quiz_params(quiz)
              )
            )
          end

          render_data(data)
        end

        def show
          authorize @quiz
          render_data(
            JSON.parse(
              Api::V1::StudentQuizSerializer.render(
                @quiz,
                params: student_quiz_params(@quiz)
              )
            )
          )
        end

        def start
          authorize @quiz
          result = Quizzes::StartAttempt.new(enrollment: @enrollment, quiz: @quiz).call
          return render_service_failure(result) if result.failure?

          render_data(
            JSON.parse(Api::V1::StudentQuizAttemptSerializer.render(result.data)),
            status: :created
          )
        end

        private

        def set_enrollment
          @enrollment = Enrollment.find_by_uuid!(params[:enrollment_uuid] || params[:uuid])
          authorize @enrollment, :show?
        end

        def set_quiz
          @quiz = Quiz.find_by_uuid!(params[:quiz_uuid])
        end

        def student_quiz_params(quiz)
          attempts = quiz.quiz_attempts.for_enrollment(@enrollment)
          completed = attempts.where(status: %i[submitted expired])
          attempts_used = completed.count
          attempts_remaining = if quiz.unlimited_attempts?
                                 nil
          else
                                 [ quiz.max_attempts - attempts_used, 0 ].max
          end
          best_percentage = attempts.where(status: :submitted).maximum(:percentage)
          has_in_progress = attempts.in_progress.exists?

          {
            attempts_used: attempts_used,
            attempts_remaining: attempts_remaining,
            best_percentage: best_percentage,
            has_in_progress_attempt: has_in_progress,
            in_progress_attempt_uuid: attempts.in_progress.first&.uuid,
            passed: attempts.where(status: :submitted, passed: true).exists?
          }
        end
      end
    end
  end
end
