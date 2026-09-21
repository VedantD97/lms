module Api
  module V1
    module Instructor
      class QuestionOptionsController < BaseController
        before_action :set_question, only: %i[create]
        before_action :set_option, only: %i[update destroy]

        def create
          option = @question.question_options.build(option_params)
          authorize option

          if option.save
            render_data(serialize(option, serializer: Api::V1::QuestionOptionSerializer), status: :created)
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(option))
          end
        end

        def update
          authorize @option

          if @option.update(option_params)
            render_data(serialize(@option, serializer: Api::V1::QuestionOptionSerializer))
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(@option))
          end
        end

        def destroy
          authorize @option
          @option.destroy!
          head :no_content
        end

        private

        def set_question
          @question = Question.find_by_uuid!(params[:question_uuid] || params[:uuid])
        end

        def set_option
          @option = QuestionOption.find_by_uuid!(params[:uuid])
        end

        def option_params
          params.require(:option).permit(:body, :is_correct, :position)
        end
      end
    end
  end
end
