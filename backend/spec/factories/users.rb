FactoryBot.define do
  factory :role do
    sequence(:name) { |n| Role::NAMES[n % Role::NAMES.size] }
    description { "Role description" }

    trait :super_admin do
      name { "super_admin" }
    end

    trait :admin do
      name { "admin" }
    end

    trait :instructor do
      name { "instructor" }
    end

    trait :student do
      name { "student" }
    end
  end

  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { "Test" }
    last_name { "User" }
    password { "password123" }
    password_confirmation { "password123" }
    status { :active }

    after(:create) do |user|
      user.assign_role!("student") unless user.roles.any?
    end

    trait :admin do
      after(:create) do |user|
        user.roles.destroy_all
        user.assign_role!("admin")
      end
    end

    trait :super_admin do
      after(:create) do |user|
        user.roles.destroy_all
        user.assign_role!("super_admin")
      end
    end

    trait :instructor do
      after(:create) do |user|
        user.roles.destroy_all
        user.assign_role!("instructor")
      end
    end

    trait :with_student_role do
      after(:create) do |user|
        user.assign_role!("student") unless user.student?
      end
    end
  end
end
