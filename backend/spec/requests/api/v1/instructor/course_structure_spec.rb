require "rails_helper"

RSpec.describe "Api::V1::Instructor::CourseStructure", type: :request do
  let(:instructor) { create(:user, :instructor) }
  let(:course) { create(:course, created_by: instructor) }

  describe "course module and lesson management" do
    it "creates modules, lessons, and resources" do
      post "/api/v1/instructor/courses/#{course.uuid}/modules",
           params: { module: { title: "Intro", position: 1, status: "published" } },
           headers: auth_headers(instructor)
      module_uuid = json_response.dig("data", "uuid")

      post "/api/v1/instructor/modules/#{module_uuid}/lessons",
           params: { lesson: { title: "Welcome", content: "Hello", status: "published" } },
           headers: auth_headers(instructor)
      lesson_uuid = json_response.dig("data", "uuid")

      post "/api/v1/instructor/lessons/#{lesson_uuid}/resources",
           params: { resource: { title: "Slides", resource_type: "link", external_url: "https://example.com" } },
           headers: auth_headers(instructor)

      expect(response).to have_http_status(:created)
      expect(json_response.dig("data", "title")).to eq("Slides")
    end
  end
end
