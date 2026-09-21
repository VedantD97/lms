module Api
  module V1
    module Instructor
      class QuestionsController < BaseController
        before_action :set_quiz, only: %i[index create reorder]
        before_action :set_question, only: %i[update destroy]

        def index
          authorize @quiz, :show?
          questions = @quiz.questions.ordered.includes(:question_options)
          render_data(serialize_collection(questions, serializer: Api::V1::QuestionSerializer))
        end

        def create
          question = @quiz.questions.build(question_params)
          authorize question

          if question.save
            render_data(serialize(question, serializer: Api::V1::QuestionSerializer), status: :created)
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(question))
          end
        end

        def update
          authorize @question

          if @question.update(question_params)
            render_data(serialize(@question, serializer: Api::V1::QuestionSerializer))
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(@question))
          end
        end

        def destroy
          authorize @question
          @question.destroy!
          head :no_content
        end

        def reorder
          authorize @quiz, :update?
          questions = @quiz.questions.ordered
          result = Courses::ReorderRecords.new(
            records: questions,
            ordered_uuids: params.require(:ordered_uuids)
          ).call

          return render_service_failure(result) if result.failure?

          render_data(serialize_collection(result.data, serializer: Api::V1::QuestionSerializer))
        end

        private

        def set_quiz
          @quiz = Quiz.find_by_uuid!(params[:quiz_uuid] || params[:uuid])
        end

        def set_question
          @question = Question.find_by_uuid!(params[:uuid])
        end

        def question_params
          params.require(:question).permit(:question_type, :body, :points, :position, :explanation)
        end
      end
    end
  end
end
