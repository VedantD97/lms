module ServiceResult
  class Base
    attr_reader :data, :errors, :error_code

    def initialize(success:, data: nil, errors: nil, error_code: nil)
      @success = success
      @data = data
      @errors = errors || []
      @error_code = error_code
    end

    def success?
      @success
    end

    def failure?
      !success?
    end

    def self.success(data = nil)
      new(success: true, data: data)
    end

    def self.failure(errors:, error_code: "validation_error")
      new(success: false, errors: Array(errors), error_code: error_code)
    end
  end
end
