module Auth
  class ResetPassword
    def initialize(token:, password:, password_confirmation:)
      @token = token
      @password = password
      @password_confirmation = password_confirmation
    end

    def call
      if token.blank?
        return ServiceResult::Base.failure(
          errors: [ { field: "token", message: "Token is required" } ],
          error_code: "validation_error"
        )
      end

      reset_token = PasswordResetToken.usable.find_by(
        token_digest: PasswordResetToken.digest(token)
      )

      unless reset_token
        return ServiceResult::Base.failure(
          errors: [ { field: "token", message: "Invalid or expired reset token" } ],
          error_code: "invalid_token"
        )
      end

      user = reset_token.user
      user.password = password
      user.password_confirmation = password_confirmation

      unless user.valid?
        return ServiceResult::Base.failure(
          errors: validation_errors(user),
          error_code: "validation_error"
        )
      end

      ActiveRecord::Base.transaction do
        user.save!
        reset_token.use!
        user.refresh_tokens.active.find_each(&:revoke!)
      end

      ServiceResult::Base.success(user)
    end

    private

    attr_reader :token, :password, :password_confirmation

    def validation_errors(record)
      record.errors.map do |error|
        { field: error.attribute.to_s, message: error.full_message }
      end
    end
  end
end
