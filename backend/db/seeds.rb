# frozen_string_literal: true

roles = [
  { name: "super_admin", description: "Full system access" },
  { name: "admin", description: "Organization administrator" },
  { name: "instructor", description: "Course instructor" },
  { name: "student", description: "Learner" }
]

roles.each do |attributes|
  Role.find_or_create_by!(name: attributes[:name]) do |role|
    role.description = attributes[:description]
  end
end

seed_demo = Rails.env.development? || Rails.env.test? || ENV["SEED_DUMMY_DATA"].present?

if seed_demo
  require_relative "seeds/demo_data"
  Seeds::DemoData.seed!
else
  admin = User.find_or_initialize_by(email: "admin@example.com")
  unless admin.persisted?
    admin.assign_attributes(
      first_name: "System",
      last_name: "Admin",
      password: "password123",
      password_confirmation: "password123",
      status: :active
    )
    admin.save!
    admin.assign_role!("admin")
  end

  puts "Seeded roles and admin user. Set SEED_DUMMY_DATA=1 to load demo records."
end
