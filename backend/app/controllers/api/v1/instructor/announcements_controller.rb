module Api
  module V1
    module Instructor
      class AnnouncementsController < BaseController
        before_action :set_course, only: %i[index create]
        before_action :set_announcement, only: %i[show update destroy publish]

        def index
          authorize @course, :show?
          announcements = @course.announcements.includes(:author).order(created_at: :desc)
          render_data(serialize_collection(announcements, serializer: Api::V1::AnnouncementSerializer))
        end

        def show
          authorize @announcement
          render_data(serialize(@announcement, serializer: Api::V1::AnnouncementSerializer))
        end

        def create
          announcement = @course.announcements.build(
            announcement_params.merge(author: current_user, audience: :course)
          )
          authorize announcement

          if announcement.save
            render_data(serialize(announcement, serializer: Api::V1::AnnouncementSerializer), status: :created)
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(announcement))
          end
        end

        def update
          authorize @announcement

          if @announcement.update(announcement_params)
            render_data(serialize(@announcement, serializer: Api::V1::AnnouncementSerializer))
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(@announcement))
          end
        end

        def destroy
          authorize @announcement
          @announcement.destroy!
          head :no_content
        end

        def publish
          authorize @announcement, :publish?
          result = Announcements::PublishAnnouncement.new(announcement: @announcement).call
          return render_service_failure(result) if result.failure?

          render_data(serialize(result.data, serializer: Api::V1::AnnouncementSerializer))
        end

        private

        def set_course
          @course = Course.find_by_uuid!(params[:course_uuid])
        end

        def set_announcement
          @announcement = Announcement.find_by_uuid!(params[:uuid])
        end

        def announcement_params
          params.require(:announcement).permit(:title, :body)
        end
      end
    end
  end
end
