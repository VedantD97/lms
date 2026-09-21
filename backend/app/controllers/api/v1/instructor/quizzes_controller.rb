module Api
  module V1
    module Instructor
      class QuizzesController < BaseController
        before_action :set_lesson, only: %i[index create]
        before_action :set_course, only: %i[index create]
        before_action :set_quiz, only: %i[show update destroy publish unpublish attempts]

        def index
          quizzes = if @lesson
                      @lesson.quizzes.order(created_at: :desc)
          else
                      @course.quizzes.order(created_at: :desc)
          end
          authorize Quiz
          render_data(serialize_collection(quizzes, serializer: Api::V1::QuizSerializer))
        end

        def show
          authorize @quiz
          render_data(serialize(@quiz, serializer: Api::V1::QuizDetailSerializer))
        end

        def create
          quiz = (@lesson || @course).quizzes.build(quiz_params)
          quiz.course = @lesson ? @lesson.course_module.course : @course
          authorize quiz

          if quiz.save
            render_data(serialize(quiz, serializer: Api::V1::QuizDetailSerializer), status: :created)
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(quiz))
          end
        end

        def update
          authorize @quiz

          if @quiz.update(quiz_params)
            render_data(serialize(@quiz, serializer: Api::V1::QuizDetailSerializer))
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(@quiz))
          end
        end

        def destroy
          authorize @quiz
          @quiz.destroy!
          head :no_content
        end

        def publish
          authorize @quiz, :publish?
          @quiz.update!(status: :published)
          render_data(serialize(@quiz, serializer: Api::V1::QuizSerializer))
        end

        def unpublish
          authorize @quiz, :unpublish?
          @quiz.update!(status: :draft)
          render_data(serialize(@quiz, serializer: Api::V1::QuizSerializer))
        end

        def attempts
          authorize @quiz, :view_attempts?
          attempts = @quiz.quiz_attempts.includes(:enrollment).order(submitted_at: :desc)
          records, meta = paginate(attempts)
          render_data(serialize_collection(records, serializer: Api::V1::QuizAttemptSerializer), meta: meta)
        end

        private

        def set_lesson
          lesson_uuid = params[:lesson_uuid]
          return if lesson_uuid.blank?

          @lesson = Lesson.find_by_uuid!(lesson_uuid)
        end

        def set_course
          @course = if @lesson
                      @lesson.course_module.course
          else
                      Course.find_by_uuid!(params[:course_uuid])
          end
        end

        def set_quiz
          @quiz = Quiz.includes(questions: :question_options).find_by_uuid!(params[:uuid])
        end

        def quiz_params
          params.require(:quiz).permit(
            :title, :description, :time_limit_minutes, :passing_score, :max_attempts,
            :shuffle_questions, :shuffle_answers, :show_correct_answers, :status,
            :available_from, :available_until, :lesson_uuid, :required_for_completion
          )
        end
      end
    end
  end
end
