module Api
  module V1
    module Auth
      class SessionsController < BaseController
        def create
          validated = validate_params!(Validators::LoginValidator, source: auth_params)
          return unless validated

          result = ::Auth::AuthenticateUser.new(
            email: validated.email,
            password: validated.password,
            request: request
          ).call
          if result.failure?
            return render_service_failure(result, status: :unauthorized)
          end

          set_refresh_token_cookie(result.data[:refresh_token])
          render_data(session_payload(result), status: :ok)
        end

        def refresh
          result = ::Auth::RefreshSession.new(
            raw_refresh_token: refresh_token_from_cookie,
            request: request
          ).call

          if result.failure?
            clear_refresh_token_cookie
            return render_service_failure(result, status: :unauthorized)
          end

          set_refresh_token_cookie(result.data[:refresh_token])
          render_data(session_payload(result), status: :ok)
        end

        def destroy
          ::Auth::RevokeSession.new(raw_refresh_token: refresh_token_from_cookie).call
          clear_refresh_token_cookie
          head :no_content
        end

        private

        def auth_params
          params.require(:auth).permit(:email, :password)
        end

        def session_payload(result)
          {
            access_token: result.data[:access_token],
            token_type: "Bearer",
            user: JSON.parse(Api::V1::UserSerializer.render(result.data[:user]))
          }
        end
      end
    end
  end
end
