class PasswordResetMailer < ApplicationMailer
  def reset_instructions(user, raw_token)
    @user = user
    @reset_url = reset_url(raw_token)

    mail(to: @user.email, subject: "Reset your LMS password")
  end

  private

  def reset_url(raw_token)
    "#{Rails.configuration.x.frontend_url}/reset-password?token=#{raw_token}"
  end
end
