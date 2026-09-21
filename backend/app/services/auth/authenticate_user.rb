module Auth
  class AuthenticateUser
    def initialize(email:, password:, request:)
      @email = email
      @password = password
      @request = request
    end

    def call
      user = User.with_roles.find_by(email: normalized_email)

      unless user&.authenticate_active_for_password?(password)
        return ServiceResult::Base.failure(
          errors: [ { field: "base", message: "Invalid email or password" } ],
          error_code: "invalid_credentials"
        )
      end

      user.update!(last_sign_in_at: Time.current)
      Auth::IssueTokens.new(user: user, request: request).call
    end

    private

    attr_reader :email, :password, :request

    def normalized_email
      email.to_s.strip.downcase
    end
  end
end
