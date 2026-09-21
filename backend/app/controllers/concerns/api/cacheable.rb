module Api
  module Cacheable
    extend ActiveSupport::Concern

    private

    def fetch_cached(key, expires_in: 2.minutes, &block)
      Rails.cache.fetch(key, expires_in: expires_in, &block)
    end
  end
end
