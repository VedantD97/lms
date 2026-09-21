module Api
  module CourseFiltering
    extend ActiveSupport::Concern

    private

    def filtered_courses(scope)
      scope.filtered(filter_params)
    end

    def filter_params
      params.permit(:q, :status, :level, :category).to_h.symbolize_keys
    end
  end
end
