module Api
  module ErrorHandling
    extend ActiveSupport::Concern

    included do
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
      rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
    end

    private

    def render_error(code:, message:, status:, details: nil)
      payload = {
        error: {
          code: code,
          message: message
        }
      }
      payload[:error][:details] = details if details.present?

      render json: payload, status: status
    end

    def render_not_found
      render_error(
        code: "not_found",
        message: "Resource not found",
        status: :not_found
      )
    end

    def render_record_invalid(exception)
      render_error(
        code: "validation_error",
        message: "Validation failed",
        status: :unprocessable_entity,
        details: exception.record.errors.map do |error|
          { field: error.attribute.to_s, message: error.full_message }
        end
      )
    end

    def render_parameter_missing(exception)
      render_error(
        code: "parameter_missing",
        message: exception.message,
        status: :bad_request
      )
    end

    def render_service_failure(result, status: :unprocessable_entity)
      render_error(
        code: result.error_code,
        message: result.errors.first&.dig(:message) || "Request failed",
        status: status,
        details: result.errors
      )
    end
  end
end
