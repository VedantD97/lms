module Api
  module V1
    class CategoriesController < BaseController
      include Api::Cacheable

      def index
        payload = fetch_cached(Cache::Keys::CATEGORIES_INDEX, expires_in: 5.minutes) do
          categories = Category.roots.includes(:children).order(:position, :name)
          records, meta = paginate(categories)
          {
            data: serialize_collection(records, serializer: Api::V1::CategorySerializer),
            meta: meta
          }
        end
        render_data(payload[:data], meta: payload[:meta])
      end
    end
  end
end
