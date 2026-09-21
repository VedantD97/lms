module Announcements
  class PublishAnnouncement
    def initialize(announcement:)
      @announcement = announcement
    end

    def call
      return failure("Announcement is already published", "invalid_state") if announcement.published?

      ActiveRecord::Base.transaction do
        announcement.update!(published_at: Time.current)
        notify_recipients
      end

      ServiceResult::Base.success(announcement.reload)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult::Base.failure(
        errors: e.record.errors.map { |err| { field: err.attribute.to_s, message: err.full_message } },
        error_code: "validation_error"
      )
    end

    private

    attr_reader :announcement

    def notify_recipients
      recipients.find_each do |user|
        Notifications::CreateNotification.new(
          user: user,
          notification_type: :announcement,
          payload: announcement_payload
        ).call
      end
    end

    def recipients
      if announcement.global?
        User.joins(:roles).where(roles: { name: "student" }, status: User.statuses[:active]).distinct
      else
        User.joins(:enrollments)
            .merge(Enrollment.active.where(course_id: announcement.course_id))
            .distinct
      end
    end

    def announcement_payload
      {
        title: announcement.title,
        body: announcement.body.truncate(500),
        announcement_uuid: announcement.uuid,
        audience: announcement.audience,
        course_uuid: announcement.course&.uuid,
        course_title: announcement.course&.title
      }
    end

    def failure(message, code)
      ServiceResult::Base.failure(errors: [ { field: "base", message: message } ], error_code: code)
    end
  end
end
