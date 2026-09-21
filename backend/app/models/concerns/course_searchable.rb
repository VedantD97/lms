module CourseSearchable
  extend ActiveSupport::Concern

  class_methods do
    def filtered(params)
      scope = all
      scope = scope.where(status: params[:status]) if params[:status].present?
      scope = scope.where(level: params[:level]) if params[:level].present?
      scope = scope.where("courses.title ILIKE :q OR courses.description ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?

      if params[:category].present?
        scope = scope.joins(:categories).where(categories: { slug: params[:category] })
      end

      scope.distinct
    end
  end
end
