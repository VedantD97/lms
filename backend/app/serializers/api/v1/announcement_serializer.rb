module Api
  module V1
    class AnnouncementSerializer < ApplicationSerializer
      attributes :uuid, :title, :body, :audience, :published_at

      attribute :published do |announcement|
        announcement.published?
      end

      attribute :course_uuid do |announcement|
        announcement.course&.uuid
      end

      attribute :author do |announcement|
        user = announcement.author
        {
          uuid: user.uuid,
          first_name: user.first_name,
          last_name: user.last_name
        }
      end
    end
  end
end
