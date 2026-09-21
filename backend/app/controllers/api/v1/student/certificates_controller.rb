module Api
  module V1
    module Student
      class CertificatesController < BaseController
        before_action :set_certificate, only: :show

        def index
          certificates = policy_scope(Certificate)
                         .active
                         .includes(enrollment: :course)
                         .order(issued_at: :desc)
          authorize Certificate
          render_data(serialize_collection(certificates, serializer: Api::V1::StudentCertificateSerializer))
        end

        def show
          authorize @certificate
          return head :not_found if @certificate.revoked?

          render_data(serialize(@certificate, serializer: Api::V1::StudentCertificateSerializer))
        end

        private

        def set_certificate
          @certificate = Certificate.includes(enrollment: :course).find_by_uuid!(params[:uuid])
        end
      end
    end
  end
end
