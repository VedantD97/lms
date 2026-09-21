module Api
  module V1
    module Student
      class BaseController < Api::V1::BaseController
        include Api::Authorization

        before_action :authenticate_user!
        before_action :require_student!
      end
    end
  end
end
