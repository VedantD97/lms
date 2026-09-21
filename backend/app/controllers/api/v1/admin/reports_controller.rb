module Api
  module V1
    module Admin
      class ReportsController < BaseController
        include Api::Cacheable

        def dashboard
          authorize :report, :dashboard?
          summary = fetch_cached(Cache::Keys.admin_dashboard(current_user.uuid), expires_in: 1.minute) do
            Reports::DashboardSummary.new.call
          end
          render_data(summary)
        end

        def enrollments
          authorize :report, :enrollments?
          report = Reports::EnrollmentsReport.new(
            from: parse_time(params[:from]),
            to: parse_time(params[:to]),
            course: course_from_param,
            status: params[:status]
          ).call
          render_data(report)
        end

        def course_completion
          authorize :report, :course_completion?
          render_data(Reports::CourseCompletionReport.new.call)
        end

        private

        def parse_time(value)
          return if value.blank?

          Time.zone.parse(value)
        rescue ArgumentError
          nil
        end

        def course_from_param
          return if params[:course_uuid].blank?

          Course.find_by_uuid!(params[:course_uuid])
        end
      end
    end
  end
end
