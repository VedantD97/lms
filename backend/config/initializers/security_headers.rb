Rails.application.config.action_dispatch.default_headers.merge!(
  "X-Frame-Options" => "DENY",
  "X-Content-Type-Options" => "nosniff",
  "Referrer-Policy" => "strict-origin-when-cross-origin",
  "Permissions-Policy" => "camera=(), microphone=(), geolocation=()",
  "X-XSS-Protection" => "0",
  "Content-Security-Policy" => "default-src 'none'; frame-ancestors 'none'"
)
