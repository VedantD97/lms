module Notifications
  class CreateNotification
    def initialize(user:, notification_type:, payload:)
      @user = user
      @notification_type = notification_type
      @payload = payload
    end

    def call
      notification = Notification.create!(
        user: user,
        notification_type: notification_type,
        payload: payload
      )

      ServiceResult::Base.success(notification)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult::Base.failure(
        errors: e.record.errors.map { |err| { field: err.attribute.to_s, message: err.full_message } },
        error_code: "validation_error"
      )
    end

    private

    attr_reader :user, :notification_type, :payload
  end
end
