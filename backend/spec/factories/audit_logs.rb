FactoryBot.define do
  factory :audit_log do
    actor { association :user, :admin }
    action { "certificate.revoked" }
    metadata { { certificate_number: "LMS-TEST-001" } }
    ip_address { "127.0.0.1" }

    trait :with_auditable do
      association :auditable, factory: :enrollment
    end
  end
end
