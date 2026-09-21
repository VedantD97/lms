module Api
  module V1
    module Validators
      class ForgotPasswordValidator < Base
        attr_accessor :email

        validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
      end
    end
  end
end
