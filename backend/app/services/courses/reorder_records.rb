module Courses
  class ReorderRecords
    def initialize(records:, ordered_uuids:)
      @records = records
      @ordered_uuids = ordered_uuids
    end

    def call
      if ordered_uuids.blank?
        return ServiceResult::Base.failure(
          errors: [ { field: "ordered_uuids", message: "is required" } ],
          error_code: "validation_error"
        )
      end

      record_map = records.index_by(&:uuid)
      missing = ordered_uuids - record_map.keys

      if missing.any?
        return ServiceResult::Base.failure(
          errors: [ { field: "ordered_uuids", message: "contains unknown identifiers" } ],
          error_code: "validation_error"
        )
      end

      if ordered_uuids.size != records.size
        return ServiceResult::Base.failure(
          errors: [ { field: "ordered_uuids", message: "must include all items" } ],
          error_code: "validation_error"
        )
      end

      ActiveRecord::Base.transaction do
        ordered_uuids.each_with_index do |uuid, index|
          record_map.fetch(uuid).update!(position: index)
        end
      end

      ServiceResult::Base.success(records.first.class.where(id: records.map(&:id)).ordered.to_a)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult::Base.failure(
        errors: e.record.errors.map { |error| { field: error.attribute.to_s, message: error.full_message } },
        error_code: "validation_error"
      )
    end

    private

    attr_reader :records, :ordered_uuids
  end
end
