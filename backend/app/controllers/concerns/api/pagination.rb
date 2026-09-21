module Api
  module Pagination
    extend ActiveSupport::Concern

    private

    def paginate(scope)
      pagy, records = pagy(scope)
      [ records, pagy_metadata(pagy) ]
    end

    def pagy_metadata(pagy)
      {
        page: pagy.page,
        per_page: pagy.limit,
        total: pagy.count
      }
    end
  end
end
