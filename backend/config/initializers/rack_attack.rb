class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  safelist("allow health check") do |req|
    req.path == "/api/v1/health"
  end

  throttle("auth/login/ip", limit: ENV.fetch("RATE_LIMIT_LOGIN", 5).to_i, period: 20.minutes) do |req|
    req.ip if req.post? && req.path == "/api/v1/auth/login"
  end

  throttle("auth/register/ip", limit: ENV.fetch("RATE_LIMIT_REGISTER", 3).to_i, period: 1.hour) do |req|
    req.ip if req.post? && req.path == "/api/v1/auth/register"
  end

  throttle("auth/forgot_password/ip", limit: ENV.fetch("RATE_LIMIT_FORGOT_PASSWORD", 5).to_i, period: 1.hour) do |req|
    req.ip if req.post? && req.path == "/api/v1/auth/forgot_password"
  end

  throttle("auth/reset_password/ip", limit: ENV.fetch("RATE_LIMIT_RESET_PASSWORD", 5).to_i, period: 1.hour) do |req|
    req.ip if req.post? && req.path == "/api/v1/auth/reset_password"
  end

  throttle("api/ip", limit: ENV.fetch("RATE_LIMIT_API", 300).to_i, period: 5.minutes) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"]
    retry_after = match_data ? match_data[:period].to_s : "300"
    headers = {
      "Content-Type" => "application/json",
      "Retry-After" => retry_after
    }
    body = {
      error: {
        code: "rate_limit_exceeded",
        message: "Too many requests. Please try again later."
      }
    }.to_json
    [429, headers, [body]]
  end
end
