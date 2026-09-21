module Api
  module V1
    class HealthController < BaseController
      def show
        render_data({ status: "ok", timestamp: Time.current.iso8601 })
      end
    end
  end
end
