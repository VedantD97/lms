module Api
  module V1
    module Validators
      class ResetPasswordValidator < Base
        attr_accessor :token, :password, :password_confirmation

        validates :token, presence: true
        validates :password, presence: true, length: { minimum: 8 }
        validates :password_confirmation, presence: true
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
