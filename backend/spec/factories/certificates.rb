FactoryBot.define do
  factory :certificate do
    enrollment
    certificate_number { "LMS-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}" }
    issued_at { Time.current }

    after(:build) do |certificate|
      next if certificate.enrollment.completed?

      certificate.enrollment.status = :completed
      certificate.enrollment.completed_at ||= Time.current
      certificate.enrollment.progress_percent = 100
    end

    trait :revoked do
      revoked_at { Time.current }
    end
  end
end
