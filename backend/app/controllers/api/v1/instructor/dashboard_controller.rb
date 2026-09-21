module Api
  module V1
    module Instructor
      class DashboardController < BaseController
        include Api::Cacheable

        def show
          authorize :instructor_dashboard, :show?
          summary = fetch_cached(Cache::Keys.instructor_dashboard(current_user.uuid), expires_in: 1.minute) do
            ::Instructor::DashboardSummary.new(instructor: current_user).call
          end
          render_data(summary)
        end
      end
    end
  end
end
