module Api
  module V1
    module Student
      class ReviewsController < BaseController
        before_action :set_course, only: %i[index create]
        before_action :set_review, only: %i[update destroy]

        def index
          authorize @course, :show?
          reviews = @course.reviews.includes(:user).recent
          records, meta = paginate(reviews)
          render_data(
            serialize_collection(records, serializer: Api::V1::ReviewSerializer),
            meta: meta.merge(
              average_rating: @course.average_rating,
              review_count: @course.review_count
            )
          )
        end

        def create
          authorize @course, :show?
          review = @course.reviews.build(review_params.merge(user: current_user))
          authorize review

          if review.save
            render_data(serialize(review, serializer: Api::V1::ReviewSerializer), status: :created)
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(review))
          end
        end

        def update
          authorize @review

          if @review.update(review_params)
            render_data(serialize(@review, serializer: Api::V1::ReviewSerializer))
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(@review))
          end
        end

        def destroy
          authorize @review
          @review.destroy!
          head :no_content
        end

        private

        def set_course
          @course = Course.find_by_uuid!(params[:course_uuid] || params[:uuid])
        end

        def set_review
          @review = Review.find_by_uuid!(params[:uuid])
        end

        def review_params
          params.require(:review).permit(:rating, :body)
        end
      end
    end
  end
end
