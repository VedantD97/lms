require "rails_helper"

RSpec.describe Certificates::IssueCertificate do
  let(:course) { create(:course, :published) }
  let(:enrollment) { create(:enrollment, course: course, status: :completed, progress_percent: 100, completed_at: Time.current) }

  it "issues a certificate for a completed enrollment" do
    result = described_class.new(enrollment: enrollment).call

    expect(result).to be_success
    expect(result.data.certificate_number).to start_with("LMS-")
    expect(result.data.enrollment).to eq(enrollment)
  end

  it "is idempotent for active certificates" do
    certificate = create(:certificate, enrollment: enrollment)

    result = described_class.new(enrollment: enrollment.reload).call

    expect(result.data.uuid).to eq(certificate.uuid)
  end

  it "rejects incomplete enrollments" do
    enrollment.update!(status: :active, completed_at: nil)

    result = described_class.new(enrollment: enrollment).call

    expect(result).to be_failure
    expect(result.error_code).to eq("invalid_state")
  end

  it "rejects reissue after revocation" do
    create(:certificate, :revoked, enrollment: enrollment)

    result = described_class.new(enrollment: enrollment.reload).call

    expect(result).to be_failure
  end
end

RSpec.describe Certificates::RevokeCertificate do
  let(:certificate) { create(:certificate) }

  it "revokes an active certificate" do
    result = described_class.new(certificate: certificate).call

    expect(result).to be_success
    expect(result.data).to be_revoked
  end

  it "rejects duplicate revocation" do
    described_class.new(certificate: certificate).call

    result = described_class.new(certificate: certificate.reload).call

    expect(result).to be_failure
  end
end

RSpec.describe Progress::RecalculateCourseProgress do
  let(:course) { create(:course, :published) }
  let(:course_module) { create(:course_module, course: course, status: :published) }
  let!(:lesson) { create(:lesson, course_module: course_module, status: :published) }
  let(:enrollment) { create(:enrollment, course: course) }

  before do
    enrollment.lesson_progresses.create!(lesson: lesson, status: :completed, progress_percent: 100)
  end

  it "auto-issues a certificate when enrollment becomes completed" do
    described_class.new(enrollment: enrollment).call

    enrollment.reload
    expect(enrollment).to be_completed
    expect(enrollment.certificate).to be_present
    expect(enrollment.certificate.certificate_number).to start_with("LMS-")
  end
end
