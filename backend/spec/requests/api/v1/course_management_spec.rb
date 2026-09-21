require "rails_helper"

RSpec.describe "Api::V1::Admin::Courses management", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "POST /api/v1/admin/courses/:uuid/publish" do
    it "publishes a course" do
      course = create(:course, status: :draft)

      post "/api/v1/admin/courses/#{course.uuid}/publish", headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "status")).to eq("published")
    end
  end

  describe "POST /api/v1/admin/courses/:uuid/archive" do
    it "archives a course" do
      course = create(:course, :published)

      post "/api/v1/admin/courses/#{course.uuid}/archive", headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "status")).to eq("archived")
    end
  end

  describe "GET /api/v1/admin/courses" do
    it "filters courses by status" do
      create(:course, :published, title: "Published")
      create(:course, title: "Draft Course", status: :draft)

      get "/api/v1/admin/courses", params: { status: "published" }, headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      titles = json_response.fetch("data").map { |course| course["title"] }
      expect(titles).to include("Published")
      expect(titles).not_to include("Draft Course")
    end
  end
end

RSpec.describe "Api::V1::Instructor::Courses management", type: :request do
  let(:instructor) { create(:user, :instructor) }

  describe "PATCH /api/v1/instructor/courses/:course_uuid/modules/reorder" do
    it "reorders modules" do
      course = create(:course, created_by: instructor)
      course.course_instructors.find_or_create_by!(user: instructor, role: :lead)
      first_module = create(:course_module, course: course, title: "A")
      second_module = create(:course_module, course: course, title: "B")

      patch "/api/v1/instructor/courses/#{course.uuid}/modules/reorder",
            params: { ordered_uuids: [ second_module.uuid, first_module.uuid ] },
            headers: auth_headers(instructor)

      expect(response).to have_http_status(:ok)
      expect(first_module.reload.position).to eq(1)
    end
  end
end
