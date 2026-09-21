module Api
  module V1
    class CertificateSerializer < ApplicationSerializer
      attributes :uuid, :certificate_number, :issued_at, :revoked_at

      attribute :enrollment_uuid do |certificate|
        certificate.enrollment.uuid
      end

      attribute :course do |certificate|
        course = certificate.enrollment.course
        {
          uuid: course.uuid,
          title: course.title,
          slug: course.slug
        }
      end

      attribute :student do |certificate|
        user = certificate.enrollment.user
        {
          uuid: user.uuid,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email
        }
      end

      attribute :revoked do |certificate|
        certificate.revoked?
      end
    end
  end
end
