module Api
  module V1
    class NotificationSerializer < ApplicationSerializer
      attributes :uuid, :notification_type, :payload, :read_at, :created_at

      attribute :read do |notification|
        notification.read?
      end
    end
  end
end
