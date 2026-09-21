module Certificates
  class RevokeCertificate
    def initialize(certificate:)
      @certificate = certificate
    end

    def call
      return failure("Certificate is already revoked", "invalid_state") if certificate.revoked?

      certificate.update!(revoked_at: Time.current)
      ServiceResult::Base.success(certificate.reload)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult::Base.failure(
        errors: e.record.errors.map { |err| { field: err.attribute.to_s, message: err.full_message } },
        error_code: "validation_error"
      )
    end

    private

    attr_reader :certificate

    def failure(message, code)
      ServiceResult::Base.failure(errors: [ { field: "base", message: message } ], error_code: code)
    end
  end
end
