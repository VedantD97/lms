module Api
  module V1
    class AuthSessionSerializer < ApplicationSerializer
      root_key :session, :session

      attribute :access_token do |session|
        session.access_token
      end

      attribute :token_type do
        "Bearer"
      end

      one :user, resource: UserSerializer
    end
  end
end