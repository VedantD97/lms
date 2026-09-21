require "rails_helper"

RSpec.describe Notifications::CreateNotification do
  let(:user) { create(:user) }

  it "creates a notification" do
    result = described_class.new(
      user: user,
      notification_type: :announcement,
      payload: { title: "Hello", body: "World" }
    ).call

    expect(result).to be_success
    expect(result.data.read?).to be(false)
  end
end

RSpec.describe Announcements::PublishAnnouncement do
  let(:student) { create(:user) }
  let(:announcement) { create(:announcement, audience: :global) }

  before do
    student.assign_role!("student")
  end

  it "publishes and notifies students" do
    result = described_class.new(announcement: announcement).call

    expect(result).to be_success
    expect(result.data).to be_published
    expect(Notification.where(user: student, notification_type: :announcement)).to exist
  end

  it "notifies enrolled students for course announcements" do
    course = create(:course, :published)
    enrollment = create(:enrollment, user: student, course: course)
    announcement = create(:announcement, :course, course: course, author: course.created_by)

    described_class.new(announcement: announcement).call

    expect(Notification.where(user: enrollment.user, notification_type: :announcement)).to exist
  end
end
