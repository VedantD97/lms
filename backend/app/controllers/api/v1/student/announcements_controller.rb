module Api
  module V1
    module Student
      class AnnouncementsController < BaseController
        def index
          announcements = policy_scope(Announcement).includes(:author, :course).order(published_at: :desc)
          records, meta = paginate(announcements)
          authorize Announcement
          render_data(serialize_collection(records, serializer: Api::V1::AnnouncementSerializer), meta: meta)
        end
      end
    end
  end
end
