module Auth
  class RequestPasswordReset
    TOKEN_TTL = 1.hour

    def initialize(email:)
      @email = email.to_s.strip.downcase
    end

    def call
      user = User.find_by(email: email)
      return ServiceResult::Base.success if user.nil?

      raw_token = SecureRandom.urlsafe_base64(32)
      user.password_reset_tokens.create!(
        token_digest: PasswordResetToken.digest(raw_token),
        expires_at: TOKEN_TTL.from_now
      )

      PasswordResetMailer.reset_instructions(user, raw_token).deliver_later

      ServiceResult::Base.success
    end

    private

    attr_reader :email
  end
end
