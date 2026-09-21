module Api
  module V1
    class StudentCourseDetailSerializer < ApplicationSerializer
      attributes :uuid, :title, :slug, :description, :short_description,
                 :status, :level, :duration_minutes, :published_at

      attribute :average_rating do |course|
        course.average_rating
      end

      attribute :review_count do |course|
        course.review_count
      end

      attribute :my_review, if: proc { params.present? && params[:current_user].present? } do |course|
        review = course.reviews.find_by(user_id: params[:current_user].id)
        next unless review

        JSON.parse(Api::V1::ReviewSerializer.render(review))
      end

      attribute :categories do |course|
        course.categories.map do |category|
          JSON.parse(Api::V1::CategorySerializer.render(category))
        end
      end

      attribute :modules do |course|
        course.course_modules.published.ordered.map do |course_module|
          {
            uuid: course_module.uuid,
            title: course_module.title,
            description: course_module.description,
            position: course_module.position,
            lessons: course_module.lessons.published.ordered.map do |lesson|
              {
                uuid: lesson.uuid,
                title: lesson.title,
                content_type: lesson.content_type,
                duration_seconds: lesson.duration_seconds,
                position: lesson.position,
                is_preview: lesson.is_preview
              }
            end
          }
        end
      end
    end
  end
end
