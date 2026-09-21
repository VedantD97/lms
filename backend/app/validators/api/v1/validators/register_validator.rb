module Api
  module V1
    module Validators
      class RegisterValidator < Base
        attr_accessor :email, :password, :password_confirmation, :first_name, :last_name

        validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
        validates :password, presence: true, length: { minimum: 8 }
        validates :password_confirmation, presence: true
        validates :first_name, :last_name, presence: true
        validate :passwords_match

        private

        def passwords_match
          return if password.blank? || password_confirmation.blank?
          return if password == password_confirmation

          errors.add(:password_confirmation, "does not match password")
        end
      end
    end
  end
end
