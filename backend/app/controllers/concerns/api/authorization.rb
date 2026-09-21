module Api
  module Authorization
    extend ActiveSupport::Concern

    private

    def require_admin!
      return if current_user&.admin_or_above?

      render_error(code: "forbidden", message: "Admin access required", status: :forbidden)
    end

    def require_instructor!
      return if current_user&.instructor? || current_user&.admin_or_above?

      render_error(code: "forbidden", message: "Instructor access required", status: :forbidden)
    end

    def require_student!
      return if current_user&.student? || current_user&.admin_or_above?

      render_error(code: "forbidden", message: "Student access required", status: :forbidden)
    end
  end
end
