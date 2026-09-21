module Api
  module V1
    module Student
      class DashboardController < BaseController
        include Api::Cacheable

        def show
          authorize :student_dashboard, :show?
          summary = fetch_cached(Cache::Keys.student_dashboard(current_user.uuid), expires_in: 1.minute) do
            ::Student::DashboardSummary.new(student: current_user).call
          end
          render_data(summary)
        end
      end
    end
  end
end
