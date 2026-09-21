require "rails_helper"

RSpec.describe LessonResource, type: :model do
  it { is_expected.to belong_to(:lesson) }
  it { is_expected.to validate_presence_of(:title) }

  it "requires an external URL for link resources" do
    resource = build(:lesson_resource, resource_type: :link, external_url: nil)
    expect(resource).not_to be_valid
  end

  it "rejects files larger than 50 MB" do
    resource = build(:lesson_resource, resource_type: :pdf)
    blob = instance_double(ActiveStorage::Blob, byte_size: 51.megabytes, content_type: "application/pdf")
    attachment = double("attachment", attached?: true, blob: blob)
    allow(resource).to receive(:file).and_return(attachment)

    expect(resource).not_to be_valid
    expect(resource.errors[:file]).to include("must be smaller than 50 MB")
  end

  it "rejects invalid content types for images" do
    resource = build(:lesson_resource, resource_type: :image)
    blob = instance_double(ActiveStorage::Blob, byte_size: 1.kilobyte, content_type: "text/plain")
    attachment = double("attachment", attached?: true, blob: blob)
    allow(resource).to receive(:file).and_return(attachment)

    expect(resource).not_to be_valid
    expect(resource.errors[:file]).to include("must be a valid image file type")
  end
end
