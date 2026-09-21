module Api
  module V1
    module Instructor
      class BaseController < Api::V1::BaseController
        include Api::Authorization

        before_action :authenticate_user!
        before_action :require_instructor!
      end
    end
  end
end
