require "rails_helper"

RSpec.describe "Authorization matrix", type: :policy do
  let(:student) { create(:user) }
  let(:other_student) { create(:user) }
  let(:instructor) { create(:user, :instructor) }
  let(:other_instructor) { create(:user, :instructor) }
  let(:admin) { create(:user, :admin) }
  let(:published_course) { create(:course, :published, created_by: instructor) }
  let(:draft_course) { create(:course, created_by: instructor) }
  let(:enrollment) { create(:enrollment, user: student, course: published_course) }
  let(:quiz) { create(:quiz, :published, course: published_course) }

  describe CoursePolicy do
    permissions :show? do
      it "allows students to view published courses" do
        expect(described_class).to permit(student, published_course)
      end

      it "denies students from viewing draft courses they are not assigned to" do
        expect(described_class).not_to permit(student, draft_course)
      end

      it "allows instructors to view their own draft courses" do
        expect(described_class).to permit(instructor, draft_course)
      end

      it "allows admins to view any course" do
        expect(described_class).to permit(admin, draft_course)
      end
    end

    permissions :update?, :publish? do
      it "allows course instructors to manage their courses" do
        expect(described_class).to permit(instructor, draft_course)
      end

      it "denies unrelated instructors" do
        expect(described_class).not_to permit(other_instructor, draft_course)
      end
    end

    permissions :destroy?, :archive? do
      it "allows admins only" do
        expect(described_class).to permit(admin, published_course)
        expect(described_class).not_to permit(instructor, published_course)
      end
    end
  end

  describe EnrollmentPolicy do
    permissions :show?, :progress? do
      it "allows owners and course instructors" do
        expect(described_class).to permit(student, enrollment)
        expect(described_class).to permit(instructor, enrollment)
      end

      it "denies unrelated students" do
        expect(described_class).not_to permit(other_student, enrollment)
      end
    end

    permissions :create? do
      it "allows students to self-enroll and admins to enroll anyone" do
        expect(described_class).to permit(student, Enrollment.new(user: student, course: published_course))
        expect(described_class).to permit(admin, Enrollment.new(user: other_student, course: published_course))
      end

      it "denies instructors from creating enrollments" do
        expect(described_class).not_to permit(instructor, Enrollment.new(user: student, course: published_course))
      end
    end

    permissions :destroy? do
      it "allows admins only" do
        expect(described_class).to permit(admin, enrollment)
        expect(described_class).not_to permit(student, enrollment)
      end
    end
  end

  describe QuizPolicy do
    permissions :show?, :start? do
      it "allows enrolled students to take published quizzes" do
        create(:enrollment, user: student, course: published_course)
        expect(described_class).to permit(student, quiz)
      end

      it "denies students who are not enrolled" do
        expect(described_class).not_to permit(other_student, quiz)
      end
    end

    permissions :update?, :destroy?, :publish? do
      it "allows course instructors and admins" do
        expect(described_class).to permit(instructor, quiz)
        expect(described_class).to permit(admin, quiz)
        expect(described_class).not_to permit(student, quiz)
      end
    end

    permissions :statistics? do
      it "allows admins only" do
        expect(described_class).to permit(admin, quiz)
        expect(described_class).not_to permit(instructor, quiz)
      end
    end
  end
end
