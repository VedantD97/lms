module Api
  module V1
    module Admin
      class AnnouncementsController < BaseController
        before_action :set_announcement, only: %i[show update destroy publish]

        def index
          announcements = policy_scope(Announcement)
                          .global
                          .includes(:author)
                          .order(created_at: :desc)
          records, meta = paginate(announcements)
          authorize Announcement
          render_data(serialize_collection(records, serializer: Api::V1::AnnouncementSerializer), meta: meta)
        end

        def show
          authorize @announcement
          render_data(serialize(@announcement, serializer: Api::V1::AnnouncementSerializer))
        end

        def create
          announcement = Announcement.new(announcement_params.merge(author: current_user, audience: :global))
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
