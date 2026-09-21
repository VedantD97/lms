module Certificates
  class IssueCertificate
    def initialize(enrollment:)
      @enrollment = enrollment
    end

    def call
      return failure("Enrollment is not completed", "invalid_state") unless enrollment.completed?

      existing = enrollment.certificate
      return ServiceResult::Base.success(existing) if existing&.active?

      if existing&.revoked?
        return failure("Certificate was revoked and cannot be reissued automatically", "invalid_state")
      end

      certificate = Certificate.create!(
        enrollment: enrollment,
        certificate_number: generate_certificate_number,
        issued_at: Time.current
      )

      ServiceResult::Base.success(certificate)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult::Base.failure(
        errors: e.record.errors.map { |err| { field: err.attribute.to_s, message: err.full_message } },
        error_code: "validation_error"
      )
    end

    private

    attr_reader :enrollment

    def generate_certificate_number
      loop do
        number = "LMS-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
        break number unless Certificate.exists?(certificate_number: number)
      end
    end

    def failure(message, code)
      ServiceResult::Base.failure(errors: [ { field: "base", message: message } ], error_code: code)
    end
  end
end
