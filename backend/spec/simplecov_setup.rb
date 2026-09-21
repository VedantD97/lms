# frozen_string_literal: true

if ENV["COVERAGE"] != "false"
  require "simplecov"

  SimpleCov.start "rails" do
    enable_coverage :branch
    minimum_coverage line: 75, branch: 45
    skip "/spec/"
    group "Policies", "app/policies"
    group "Services", "app/services"
    group "Serializers", "app/serializers"
    cover "app/**/*.rb"
  end
end
