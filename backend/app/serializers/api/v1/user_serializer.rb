module Api
  module V1
    class UserSerializer < ApplicationSerializer
      attributes :uuid, :email, :first_name, :last_name, :status, :email_verified_at, :last_sign_in_at

      attribute :roles do |user|
        user.role_names
      end

      attribute :highest_role do |user|
        user.highest_role
      end
    end
  end
end
