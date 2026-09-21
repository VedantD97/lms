FactoryBot.define do
  factory :announcement do
    association :author, factory: %i[user admin]
    sequence(:title) { |n| "Announcement #{n}" }
    body { "Important platform update for all students." }
    audience { :global }

    trait :course do
      audience { :course }
      association :course, factory: %i[course published]
    end

    trait :published do
      published_at { Time.current }
    end
  end

  factory :notification do
    user
    notification_type { :announcement }
    payload do
      {
        title: "New announcement",
        body: "Check the latest update",
        announcement_uuid: SecureRandom.uuid
      }
    end

    trait :read do
      read_at { Time.current }
    end
  end
end
