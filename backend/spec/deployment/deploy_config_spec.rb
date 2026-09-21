require "rails_helper"

RSpec.describe "Deployment configuration" do
  let(:repo_root) { Rails.root.join("..").expand_path }

  it "defines a production Docker Compose stack" do
    compose = YAML.load_file(repo_root.join("docker-compose.prod.yml"))

    expect(compose.fetch("services").keys).to include("db", "backend", "frontend", "proxy")
    expect(compose.dig("services", "backend", "environment", "RAILS_ENV")).to eq("production")
  end

  it "routes traffic through Caddy to API and SPA" do
    caddyfile = repo_root.join("deploy/Caddyfile").read

    expect(caddyfile).to include("reverse_proxy backend:80")
    expect(caddyfile).to include("reverse_proxy frontend:80")
    expect(caddyfile).to include("/api/*")
  end

  it "documents Kamal deployment settings" do
    deploy = YAML.load_file(Rails.root.join("config/deploy.yml"))

    expect(deploy.fetch("service")).to eq("lms-api")
    expect(deploy.dig("proxy", "healthcheck", "path")).to eq("/api/v1/health")
    expect(deploy.dig("env", "secret")).to include("RAILS_MASTER_KEY", "JWT_SECRET")
  end

  it "creates cache and queue databases on Postgres init" do
    init_script = repo_root.join("deploy/postgres/init-multiple-dbs.sh").read

    expect(init_script).to include("lms_production_cache")
    expect(init_script).to include("lms_production_queue")
  end

  it "supports S3 storage via environment variables" do
    storage = Rails.root.join("config/storage.yml").read

    expect(storage).to include("amazon:")
    expect(storage).to include('ENV["AWS_ACCESS_KEY_ID"]')
  end
end
