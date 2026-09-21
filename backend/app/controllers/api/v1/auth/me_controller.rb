module Api
  module V1
    module Auth
      class MeController < BaseController
        before_action :authenticate_user!

        def show
          authorize current_user, policy_class: UserPolicy
          render_data(JSON.parse(Api::V1::UserSerializer.render(current_user)))
        end
      end
    end
  end
end
