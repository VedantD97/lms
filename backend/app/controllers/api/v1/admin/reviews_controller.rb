module Api
  module V1
    module Admin
      class ReviewsController < BaseController
        before_action :set_review, only: %i[show destroy]

        def index
          reviews = policy_scope(Review).includes(:user, :course).recent
          records, meta = paginate(reviews)
          authorize Review
          render_data(serialize_collection(records, serializer: Api::V1::ReviewSerializer), meta: meta)
        end

        def show
          authorize @review
          render_data(serialize(@review, serializer: Api::V1::ReviewSerializer))
        end

        def destroy
          authorize @review
          review_snapshot = {
            course_uuid: @review.course.uuid,
            rating: @review.rating,
            user_uuid: @review.user.uuid
          }
          @review.destroy!
          record_audit!(action: "review.deleted", auditable: nil, changes: review_snapshot)
          head :no_content
        end

        private

        def set_review
          @review = Review.find_by_uuid!(params[:uuid])
        end
      end
    end
  end
end
