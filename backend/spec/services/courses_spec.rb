require "rails_helper"

RSpec.describe Courses::PublishCourse do
  it "publishes a draft course" do
    course = create(:course, status: :draft)

    result = described_class.new(course: course).call

    expect(result).to be_success
    expect(result.data).to be_published
    expect(result.data.published_at).to be_present
  end
end

RSpec.describe Courses::ReorderRecords do
  it "reorders records by uuid list" do
    course = create(:course)
    first_module = create(:course_module, course: course, position: 0, title: "First")
    second_module = create(:course_module, course: course, position: 1, title: "Second")

    result = described_class.new(
      records: course.course_modules.ordered,
      ordered_uuids: [ second_module.uuid, first_module.uuid ]
    ).call

    expect(result).to be_success
    expect(first_module.reload.position).to eq(1)
    expect(second_module.reload.position).to eq(0)
  end
end
