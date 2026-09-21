module Api
  module V1
    module Admin
      class UsersController < BaseController
        def index
          users = policy_scope(User).with_roles.order(:last_name, :first_name)
          users = users.joins(:roles).where(roles: { name: params[:role] }).distinct if params[:role].present?
          records, meta = paginate(users)
          authorize User
          render_data(serialize_collection(records, serializer: Api::V1::UserSerializer), meta: meta)
        end
      end
    end
  end
end
