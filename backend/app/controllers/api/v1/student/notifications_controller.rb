module Api
  module V1
    module Student
      class NotificationsController < BaseController
        before_action :set_notification, only: %i[show read]

        def index
          notifications = policy_scope(Notification).recent
          notifications = notifications.unread if params[:unread] == "true"
          records, meta = paginate(notifications)
          authorize Notification
          render_data(serialize_collection(records, serializer: Api::V1::NotificationSerializer), meta: meta)
        end

        def show
          authorize @notification
          render_data(serialize(@notification, serializer: Api::V1::NotificationSerializer))
        end

        def read
          authorize @notification, :read?
          @notification.mark_read!
          render_data(serialize(@notification, serializer: Api::V1::NotificationSerializer))
        end

        def read_all
          authorize Notification, :read_all?
          policy_scope(Notification).unread.update_all(read_at: Time.current)
          head :no_content
        end

        def unread_count
          authorize Notification, :unread_count?
          count = policy_scope(Notification).unread.count
          render_data({ unread_count: count })
        end

        private

        def set_notification
          @notification = Notification.find_by_uuid!(params[:uuid])
        end
      end
    end
  end
end
