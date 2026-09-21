require "rails_helper"

RSpec.describe "Api::V1::Instructor::Courses", type: :request do
  let(:instructor) { create(:user, :instructor) }

  describe "POST /api/v1/instructor/courses" do
    it "creates a draft course and assigns the instructor" do
      post "/api/v1/instructor/courses",
           params: { course: { title: "Rails API", description: "Build APIs" } },
           headers: auth_headers(instructor)

      expect(response).to have_http_status(:created)
      expect(json_response.dig("data", "status")).to eq("draft")
      expect(json_response.dig("data", "instructor_uuids")).to include(instructor.uuid)
    end
  end
end
