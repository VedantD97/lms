require "rails_helper"

RSpec.describe AuditLogs::Record do
  it "creates an audit log entry" do
    admin = create(:user, :admin)

    log = described_class.new(
      actor: admin,
      action: "review.deleted",
      changes: { rating: 5 },
      ip_address: "127.0.0.1"
    ).call

    expect(log).to be_persisted
    expect(log.action).to eq("review.deleted")
    expect(log.metadata).to eq("rating" => 5)
  end
end

RSpec.describe Reports::DashboardSummary do
  it "returns aggregate counts" do
    create(:user)
    create(:user, :instructor)
    course = create(:course, :published)
    create(:enrollment, course: course)

    summary = described_class.new.call

    expect(summary.dig(:users, :students)).to be >= 1
    expect(summary.dig(:courses, :published)).to be >= 1
    expect(summary.dig(:enrollments, :total)).to be >= 1
  end
end

RSpec.describe Reports::CourseCompletionReport do
  it "calculates completion rates per course" do
    course = create(:course, :published)
    student = create(:user)
    create(:enrollment, user: student, course: course, status: :completed, progress_percent: 100)
    create(:enrollment, course: course, status: :active, progress_percent: 50)

    rows = described_class.new.call
    row = rows.find { |item| item[:course_uuid] == course.uuid }

    expect(row[:total_enrollments]).to eq(2)
    expect(row[:completed_enrollments]).to eq(1)
    expect(row[:completion_rate]).to eq(50.0)
  end
end
