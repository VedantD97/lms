RSpec.configure do |config|
  config.before do
    Rack::Attack.cache.store.clear if Rack::Attack.cache.store.respond_to?(:clear)
  end
end
