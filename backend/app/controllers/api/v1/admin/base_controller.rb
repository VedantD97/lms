module Api
  module V1
    module Admin
      class BaseController < Api::V1::BaseController
        include Api::Authorization
        include Api::AuditLogging

        before_action :authenticate_user!
        before_action :require_admin!
      end
    end
  end
end
