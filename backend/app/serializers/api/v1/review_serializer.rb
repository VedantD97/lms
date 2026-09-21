module Api
  module V1
    class ReviewSerializer < ApplicationSerializer
      attributes :uuid, :rating, :body, :created_at, :updated_at

      attribute :course_uuid do |review|
        review.course.uuid
      end

      attribute :course do |review|
        {
          uuid: review.course.uuid,
          title: review.course.title
        }
      end

      attribute :user do |review|
        user = review.user
        {
          uuid: user.uuid,
          first_name: user.first_name,
          last_name: user.last_name
        }
      end
    end
  end
end
