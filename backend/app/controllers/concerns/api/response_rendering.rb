module Api
  module ResponseRendering
    extend ActiveSupport::Concern

    private

    def render_data(data, status: :ok, meta: nil)
      payload = { data: data }
      payload[:meta] = meta if meta.present?
      render json: payload, status: status
    end

    def serialize(record, serializer:)
      JSON.parse(serializer.render(record))
    end

    def serialize_collection(records, serializer:)
      records.map { |record| serialize(record, serializer: serializer) }
    end
  end
end
