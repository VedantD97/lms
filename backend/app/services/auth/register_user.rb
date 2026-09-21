module Auth
  class RegisterUser
    DEFAULT_ROLE = "student"

    def initialize(params:)
      @params = params
    end

    def call
      user = User.new(
        email: params[:email],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        first_name: params[:first_name],
        last_name: params[:last_name]
      )

      unless user.valid?
        return ServiceResult::Base.failure(
          errors: validation_errors(user),
          error_code: "validation_error"
        )
      end

      ActiveRecord::Base.transaction do
        user.save!
        user.assign_role!(DEFAULT_ROLE)
      end

      ServiceResult::Base.success(user.reload)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult::Base.failure(
        errors: validation_errors(e.record),
        error_code: "validation_error"
      )
    end

    private

    attr_reader :params

    def validation_errors(record)
      record.errors.map do |error|
        { field: error.attribute.to_s, message: error.full_message }
      end
    end
  end
end
