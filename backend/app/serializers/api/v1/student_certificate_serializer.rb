module Api
  module V1
    class StudentCertificateSerializer < ApplicationSerializer
      attributes :uuid, :certificate_number, :issued_at

      attribute :course do |certificate|
        course = certificate.enrollment.course
        {
          uuid: course.uuid,
          title: course.title,
          slug: course.slug
        }
      end

      attribute :completed_at do |certificate|
        certificate.enrollment.completed_at
      end
    end
  end
end
