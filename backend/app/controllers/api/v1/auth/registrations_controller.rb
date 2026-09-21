module Api
  module V1
    module Auth
      class RegistrationsController < BaseController
        def create
          validated = validate_params!(Validators::RegisterValidator, source: registration_params)
          return unless validated

          result = ::Auth::RegisterUser.new(
            params: {
              email: validated.email,
              password: validated.password,
              password_confirmation: validated.password_confirmation,
              first_name: validated.first_name,
              last_name: validated.last_name
            }
          ).call

          return render_service_failure(result) if result.failure?

          render_data(
            JSON.parse(Api::V1::UserSerializer.render(result.data)),
            status: :created
          )
        end

        private

        def registration_params
          params.require(:user).permit(
            :email,
            :password,
            :password_confirmation,
            :first_name,
            :last_name
          )
        end
      end
    end
  end
end
