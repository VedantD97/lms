class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Pagy::Backend
  include PunditHelper
end
