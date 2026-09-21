module PunditHelper
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization

    rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
  end

  private

  def render_forbidden
    render_error(
      code: "forbidden",
      message: "You are not authorized to perform this action",
      status: :forbidden
    )
  end
end
