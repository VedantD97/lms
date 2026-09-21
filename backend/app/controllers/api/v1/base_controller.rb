module Api
  module V1
    class BaseController < ApplicationController
      include Api::ErrorHandling
      include Api::Authentication
      include Api::RefreshCookie
      include Api::ParameterValidation
      include Api::ResponseRendering
      include Api::Pagination
    end
  end
end
