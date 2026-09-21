module Api
  module V1
    module Validators
      class LoginValidator < Base
        attr_accessor :email, :password

        validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
        validates :password, presence: true
      end
    end
  end
end
