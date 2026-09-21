require "rails_helper"

RSpec.describe "Api caching", type: :request do
  around do |example|
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    Rails.cache = original_cache
  end

  describe "GET /api/v1/categories" do
    it "stores the response in cache" do
      create_list(:category, 2)

      get "/api/v1/categories"
      expect(response).to have_http_status(:ok)
      expect(Rails.cache.exist?(Cache::Keys::CATEGORIES_INDEX)).to be(true)

      get "/api/v1/categories"
      expect(response).to have_http_status(:ok)
    end
  end
end
