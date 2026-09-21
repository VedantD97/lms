module Api
  module V1
    module Admin
      class CertificatesController < BaseController
        before_action :set_certificate, only: %i[show revoke]

        def index
          certificates = policy_scope(Certificate)
                         .includes(enrollment: %i[user course])
                         .order(issued_at: :desc)
          records, meta = paginate(certificates)
          authorize Certificate
          render_data(serialize_collection(records, serializer: Api::V1::CertificateSerializer), meta: meta)
        end

        def show
          authorize @certificate
          render_data(serialize(@certificate, serializer: Api::V1::CertificateSerializer))
        end

        def revoke
          authorize @certificate, :revoke?
          result = Certificates::RevokeCertificate.new(certificate: @certificate).call
          return render_service_failure(result) if result.failure?

          record_audit!(
            action: "certificate.revoked",
            auditable: result.data,
            changes: { certificate_number: result.data.certificate_number, revoked_at: result.data.revoked_at }
          )

          render_data(serialize(result.data, serializer: Api::V1::CertificateSerializer))
        end

        private

        def set_certificate
          @certificate = Certificate.includes(enrollment: %i[user course]).find_by_uuid!(params[:uuid])
        end
      end
    end
  end
end
