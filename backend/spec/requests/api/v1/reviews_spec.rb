require "rails_helper"

RSpec.describe "Api::V1::Reviews", type: :request do
  let(:student) { create(:user) }
  let(:other_student) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:course) { create(:course, :published) }
  let!(:enrollment) { create(:enrollment, user: student, course: course) }

  describe "POST /api/v1/student/courses/:uuid/reviews" do
    it "creates a review for an enrolled student" do
      post "/api/v1/student/courses/#{course.uuid}/reviews",
           params: { review: { rating: 5, body: "Excellent course!" } },
           headers: auth_headers(student)

      expect(response).to have_http_status(:created)
      expect(json_response.dig("data", "rating")).to eq(5)
      expect(course.reload.average_rating).to eq(5.0)
    end

    it "rejects review from non-enrolled student" do
      post "/api/v1/student/courses/#{course.uuid}/reviews",
           params: { review: { rating: 4, body: "Nice" } },
           headers: auth_headers(other_student)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /api/v1/student/courses/:uuid/reviews" do
    let!(:review) { create(:review, course: course, user: student, rating: 4) }

    it "lists course reviews with stats" do
      get "/api/v1/student/courses/#{course.uuid}/reviews", headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", 0, "uuid")).to eq(review.uuid)
      expect(json_response.dig("meta", "average_rating")).to eq(4.0)
    end
  end

  describe "PATCH /api/v1/student/reviews/:uuid" do
    let!(:review) { create(:review, course: course, user: student, rating: 3) }

    it "updates own review" do
      patch "/api/v1/student/reviews/#{review.uuid}",
            params: { review: { rating: 5, body: "Updated review" } },
            headers: auth_headers(student)

      expect(response).to have_http_status(:ok)
      expect(json_response.dig("data", "rating")).to eq(5)
    end
  end

  describe "DELETE /api/v1/admin/reviews/:uuid" do
    let!(:review) { create(:review, course: course, user: student) }

    it "allows admin to delete a review" do
      delete "/api/v1/admin/reviews/#{review.uuid}", headers: auth_headers(admin)

      expect(response).to have_http_status(:no_content)
      expect(Review.find_by(id: review.id)).to be_nil
    end
  end
end
