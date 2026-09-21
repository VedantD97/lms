module Api
  module V1
    module Auth
      class PasswordsController < BaseController
        def forgot
          validated = validate_params!(Validators::ForgotPasswordValidator, source: forgot_params)
          return unless validated

          ::Auth::RequestPasswordReset.new(email: validated.email).call
          render_data({ message: "If the email exists, password reset instructions have been sent." })
        end

        def reset
          validated = validate_params!(Validators::ResetPasswordValidator, source: reset_params)
          return unless validated

          result = ::Auth::ResetPassword.new(
            token: validated.token,
            password: validated.password,
            password_confirmation: validated.password_confirmation
          ).call

          return render_service_failure(result) if result.failure?

          render_data({ message: "Password has been reset successfully." })
        end

        private

        def forgot_params
          params.require(:auth).permit(:email)
        end

        def reset_params
          params.require(:auth).permit(:token, :password, :password_confirmation)
        end
      end
    end
  end
end
