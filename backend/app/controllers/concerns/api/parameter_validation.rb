module Api
  module ParameterValidation
    extend ActiveSupport::Concern

    private

    def validate_params!(validator_class, source: params)
      validator = validator_class.new(source.to_unsafe_h)

      return validator if validator.valid?

      render_error(
        code: "validation_error",
        message: "Validation failed",
        status: :unprocessable_entity,
        details: validator.errors.map do |error|
          { field: error.attribute.to_s, message: error.full_message }
        end
      )
      nil
    end
  end
end
