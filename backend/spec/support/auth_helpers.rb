module AuthHelpers
  def json_response
    JSON.parse(response.body)
  end

  def auth_headers(user)
    token = JsonWebToken.encode({ sub: user.uuid, roles: user.role_names })
    { "Authorization" => "Bearer #{token}" }
  end

  def refresh_cookie(raw_token)
    { "Cookie" => "#{Auth::IssueTokens::REFRESH_COOKIE_NAME}=#{raw_token}" }
  end
end
