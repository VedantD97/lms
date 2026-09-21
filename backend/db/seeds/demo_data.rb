# frozen_string_literal: true

module Seeds
  module DemoData
    PASSWORD = "password123"

    module_function

    def seed!
      return puts("Demo data already present — skipping.") if Course.exists?(slug: "introduction-to-ruby-on-rails")

      puts "Seeding demo data..."

      users = seed_users
      categories = seed_categories
      courses = seed_courses(users:, categories:)
      seed_announcements(users:, courses:)
      seed_enrollments_and_progress(users:, courses:)
      seed_reviews(users:, courses:)

      print_summary(users)
    end

    def seed_users
      {
        super_admin: seed_user("superadmin@example.com", "Super", "Admin", "super_admin"),
        admin: seed_user("admin@example.com", "System", "Admin", "admin"),
        instructor: seed_user("instructor@example.com", "Alex", "Rivera", "instructor"),
        instructor2: seed_user("instructor2@example.com", "Jordan", "Lee", "instructor"),
        student: seed_user("student@example.com", "Sam", "Taylor", "student"),
        student2: seed_user("student2@example.com", "Casey", "Nguyen", "student"),
        student3: seed_user("student3@example.com", "Riley", "Patel", "student"),
        student4: seed_user("student4@example.com", "Morgan", "Chen", "student")
      }
    end

    def seed_user(email, first_name, last_name, role)
      user = User.find_or_initialize_by(email: email)
      if user.new_record?
        user.assign_attributes(
          first_name: first_name,
          last_name: last_name,
          password: PASSWORD,
          password_confirmation: PASSWORD,
          status: :active
        )
        user.save!
      end
      user.assign_role!(role) unless user.role_names.include?(role)
      user
    end

    def seed_categories
      web = Category.find_or_create_by!(slug: "web-development") do |category|
        category.name = "Web Development"
        category.description = "Frontend and backend web technologies"
        category.position = 0
      end

      data = Category.find_or_create_by!(slug: "data-science") do |category|
        category.name = "Data Science"
        category.description = "Analytics, ML, and data engineering"
        category.position = 1
      end

      design = Category.find_or_create_by!(slug: "design") do |category|
        category.name = "Design"
        category.description = "UI/UX and visual design"
        category.position = 2
      end

      { web:, data:, design: }
    end

    def seed_courses(users:, categories:)
      rails = seed_rails_course(users:, categories:)
      react = seed_react_course(users:, categories:)
      postgres = seed_postgres_course(users:, categories:)
      draft = seed_draft_course(users:)

      { rails:, react:, postgres:, draft: }
    end

    def seed_rails_course(users:, categories:)
      course = Course.find_or_create_by!(slug: "introduction-to-ruby-on-rails") do |record|
        record.title = "Introduction to Ruby on Rails"
        record.description = "Build a full-stack web application with Rails 8, PostgreSQL, and modern API patterns."
        record.short_description = "Learn Rails from scratch with hands-on projects."
        record.level = :beginner
        record.duration_minutes = 480
        record.created_by = users[:instructor]
        record.status = :published
        record.published_at = 2.weeks.ago
      end

      course.categories << categories[:web] unless course.categories.include?(categories[:web])
      assign_lead_instructor(course, users[:instructor])

      module1 = seed_module(course, "Getting Started with Rails", 0)
      seed_lesson(module1, "What is Rails?", 0, <<~TEXT, preview: true)
        Rails is a full-stack web framework optimized for developer happiness.
        In this lesson you will learn the MVC pattern and how Rails apps are structured.
      TEXT
      seed_lesson(module1, "Setting Up Your Environment", 1, <<~TEXT)
        Install Ruby, PostgreSQL, and Rails. Create your first application with `rails new`.
      TEXT
      seed_lesson(module1, "Routing and Controllers", 2, <<~TEXT)
        Define routes in config/routes.rb and connect them to controller actions.
      TEXT

      module2 = seed_module(course, "Models and the Database", 1)
      lesson4 = seed_lesson(module2, "Active Record Basics", 0, <<~TEXT)
        Active Record is the ORM layer. Learn migrations, models, and associations.
      TEXT
      lesson5 = seed_lesson(module2, "Validations and Callbacks", 1, <<~TEXT)
        Keep data clean with validations and hook into the Active Record lifecycle.
      TEXT

      seed_link_resource(lesson4, "Rails Guides", "https://guides.rubyonrails.org/active_record_basics.html")

      quiz = seed_quiz(course, "Rails Basics Quiz", lesson5, passing_score: 70)
      seed_single_choice_question(quiz, "Which command creates a new Rails app?", "rails new myapp", %w[rails new myapp rails init myapp ruby create app])
      seed_single_choice_question(quiz, "Active Record is responsible for...", "Database interactions", ["Database interactions", "HTTP routing", "Asset compilation"])

      seed_assignment(course, "Build a Todo API", lesson5, due_in: 7.days, description: "Create a JSON API with CRUD endpoints for todos.")

      course
    end

    def seed_react_course(users:, categories:)
      course = Course.find_or_create_by!(slug: "react-fundamentals") do |record|
        record.title = "React Fundamentals"
        record.description = "Master components, hooks, and state management with React and TypeScript."
        record.short_description = "Modern React patterns for production apps."
        record.level = :intermediate
        record.duration_minutes = 360
        record.created_by = users[:instructor]
        record.status = :published
        record.published_at = 1.month.ago
      end

      course.categories << categories[:web] unless course.categories.include?(categories[:web])
      assign_lead_instructor(course, users[:instructor])

      module1 = seed_module(course, "React Core Concepts", 0)
      lesson1 = seed_lesson(module1, "Components and JSX", 0, "Learn functional components and JSX syntax.")
      lesson2 = seed_lesson(module1, "State and Effects", 1, "Use useState and useEffect to manage component behavior.")

      quiz = seed_quiz(course, "React Hooks Quiz", lesson2, passing_score: 75)
      seed_single_choice_question(quiz, "Which hook manages local state?", "useState", %w[useState useEffect useMemo useReducer])

      seed_assignment(course, "Counter App", lesson2, due_in: 14.days, description: "Build a counter with increment, decrement, and reset.")

      course
    end

    def seed_postgres_course(users:, categories:)
      course = Course.find_or_create_by!(slug: "advanced-postgresql") do |record|
        record.title = "Advanced PostgreSQL"
        record.description = "Indexing strategies, query planning, and performance tuning for PostgreSQL 16."
        record.short_description = "Level up your database skills."
        record.level = :advanced
        record.duration_minutes = 300
        record.created_by = users[:instructor2]
        record.status = :published
        record.published_at = 3.days.ago
      end

      course.categories << categories[:data] unless course.categories.include?(categories[:data])
      assign_lead_instructor(course, users[:instructor2])

      module1 = seed_module(course, "Query Performance", 0)
      seed_lesson(module1, "Reading EXPLAIN Plans", 0, "Understand sequential scans, index scans, and cost estimates.")
      seed_lesson(module1, "Index Types", 1, "B-tree, GIN, GiST, and partial indexes.")

      course
    end

    def seed_draft_course(users:)
      Course.find_or_create_by!(slug: "docker-basics-draft") do |record|
        record.title = "Docker Basics (Draft)"
        record.description = "Container fundamentals — not yet published."
        record.short_description = "Coming soon."
        record.level = :beginner
        record.duration_minutes = 180
        record.created_by = users[:instructor2]
        record.status = :draft
      end
    end

    def assign_lead_instructor(course, instructor)
      course.course_instructors.find_or_create_by!(user: instructor) do |record|
        record.role = :lead
      end
    end

    def seed_module(course, title, position)
      course.course_modules.find_or_create_by!(title: title) do |record|
        record.description = "#{title} module"
        record.position = position
        record.status = :published
      end
    end

    def seed_lesson(course_module, title, position, content, preview: false)
      course_module.lessons.find_or_create_by!(title: title) do |record|
        record.content = content
        record.content_type = :text
        record.position = position
        record.status = :published
        record.is_preview = preview
        record.required_for_completion = !preview
        record.duration_seconds = 600
      end
    end

    def seed_link_resource(lesson, title, url)
      lesson.lesson_resources.find_or_create_by!(title: title) do |record|
        record.resource_type = :link
        record.external_url = url
        record.position = 0
      end
    end

    def seed_quiz(course, title, lesson, passing_score:)
      course.quizzes.find_or_create_by!(title: title) do |record|
        record.description = "Check your understanding of #{lesson.title}."
        record.lesson = lesson
        record.passing_score = passing_score
        record.max_attempts = 3
        record.status = :published
        record.show_correct_answers = :after_submit
        record.required_for_completion = true
      end
    end

    def seed_single_choice_question(quiz, body, correct_answer, options)
      question = quiz.questions.find_or_initialize_by(body: body)
      return question if question.persisted? && question.question_options.any?

      question.assign_attributes(question_type: :single_choice, points: 10, position: quiz.questions.count)
      question.save!

      options.each_with_index do |option_body, index|
        question.question_options.find_or_create_by!(body: option_body) do |record|
          record.is_correct = option_body == correct_answer
          record.position = index
        end
      end

      question
    end

    def seed_assignment(course, title, lesson, due_in:, description:)
      course.assignments.find_or_create_by!(title: title) do |record|
        record.description = description
        record.lesson = lesson
        record.max_points = 100
        record.passing_score = 70
        record.allow_late = true
        record.allow_resubmit = true
        record.required_for_completion = true
        record.status = :published
        record.due_at = due_in.from_now
      end
    end

    def seed_announcements(users:, courses:)
      Announcement.find_or_create_by!(title: "Welcome to the LMS") do |record|
        record.author = users[:admin]
        record.body = "Explore published courses, track your progress, and earn certificates."
        record.audience = :global
        record.published_at = 1.week.ago
      end

      Announcement.find_or_create_by!(title: "New Rails content added") do |record|
        record.author = users[:instructor]
        record.body = "Module 2 now includes a quiz and assignment. Complete them to finish the course."
        record.audience = :course
        record.course = courses[:rails]
        record.published_at = 2.days.ago
      end
    end

    def seed_enrollments_and_progress(users:, courses:)
      seed_in_progress_student(users[:student], courses[:rails], users[:instructor])
      seed_completed_student(users[:student2], courses[:react], users[:instructor])
      seed_new_student(users[:student3], courses[:postgres])
      seed_pending_grading_student(users[:student4], courses[:rails], users[:instructor])
    end

    def seed_in_progress_student(student, course, instructor)
      enrollment = enroll_student(student, course)
      lessons = course.published_lessons.to_a
      complete_lessons(enrollment, lessons.first(2))

      quiz = course.quizzes.published.first
      start_quiz_attempt(enrollment, quiz) if quiz

      assignment = course.assignments.published.first
      submit_assignment(enrollment, assignment, "Here is my todo API submission with index and create actions.") if assignment

      Progress::RecalculateCourseProgress.new(enrollment: enrollment.reload).call
    end

    def seed_completed_student(student, course, instructor)
      enrollment = enroll_student(student, course)

      course.published_lessons.find_each do |lesson|
        Progress::MarkLessonComplete.new(enrollment: enrollment, lesson: lesson).call
      end

      course.quizzes.published.find_each do |quiz|
        pass_quiz(enrollment, quiz)
      end

      course.assignments.published.find_each do |assignment|
        result = Assignments::SubmitSubmission.new(
          enrollment: enrollment,
          assignment: assignment,
          body: "Completed #{assignment.title} with all required features."
        ).call
        next if result.failure?

        Assignments::GradeSubmission.new(
          submission: result.data,
          grader: instructor,
          points: 92,
          feedback: "Excellent work!"
        ).call
      end

      Progress::RecalculateCourseProgress.new(enrollment: enrollment.reload).call
    end

    def seed_new_student(student, course)
      enroll_student(student, course)
    end

    def seed_pending_grading_student(student, course, instructor)
      enrollment = enroll_student(student, course)
      assignment = course.assignments.published.first
      return unless assignment

      Assignments::SubmitSubmission.new(
        enrollment: enrollment,
        assignment: assignment,
        body: "Submission awaiting instructor review."
      ).call
    end

    def enroll_student(student, course)
      result = Enrollments::CreateEnrollment.new(user: student, course: course).call
      raise "Failed to enroll #{student.email} in #{course.title}: #{result.errors}" if result.failure?

      result.data
    end

    def complete_lessons(enrollment, lessons)
      lessons.each do |lesson|
        Progress::MarkLessonComplete.new(enrollment: enrollment, lesson: lesson).call
      end
    end

    def start_quiz_attempt(enrollment, quiz)
      return if quiz.blank?
      return if enrollment.quiz_attempts.where(quiz: quiz, status: :in_progress).exists?

      Quizzes::StartAttempt.new(enrollment: enrollment, quiz: quiz).call
    end

    def pass_quiz(enrollment, quiz)
      start_result = Quizzes::StartAttempt.new(enrollment: enrollment, quiz: quiz).call
      return if start_result.failure?

      attempt = start_result.data
      responses = attempt.ordered_questions.map do |question|
        correct = question.question_options.find_by(is_correct: true)
        { question_uuid: question.uuid, selected_option_uuids: [ correct.uuid ] }
      end

      Quizzes::SubmitAttempt.new(attempt: attempt, responses: responses).call
    end

    def submit_assignment(enrollment, assignment, body)
      Assignments::SubmitSubmission.new(enrollment: enrollment, assignment: assignment, body: body).call
    end

    def seed_reviews(users:, courses:)
      Review.find_or_create_by!(user: users[:student2], course: courses[:react]) do |record|
        record.rating = 5
        record.body = "Clear explanations and practical exercises. Highly recommend!"
      end

      Review.find_or_create_by!(user: users[:student], course: courses[:rails]) do |record|
        record.rating = 4
        record.body = "Great intro course. The quiz was challenging but fair."
      end

      Review.find_or_create_by!(user: users[:student4], course: courses[:rails]) do |record|
        record.rating = 5
        record.body = "Instructor feedback on assignments is very helpful."
      end
    end

    def print_summary(users)
      puts
      puts "Demo data seeded successfully."
      puts
      puts "Test accounts (password for all: #{PASSWORD}):"
      puts "  superadmin@example.com  — Super Admin"
      puts "  admin@example.com       — Admin"
      puts "  instructor@example.com  — Instructor (Rails, React courses)"
      puts "  instructor2@example.com — Instructor (PostgreSQL course)"
      puts "  student@example.com     — In progress on Rails course"
      puts "  student2@example.com    — Completed React course + certificate"
      puts "  student3@example.com    — Enrolled in PostgreSQL course"
      puts "  student4@example.com    — Pending assignment grading (Rails)"
      puts
      puts "Courses:"
      puts "  • Introduction to Ruby on Rails (published, 2 modules, quiz + assignment)"
      puts "  • React Fundamentals (published, completed by student2)"
      puts "  • Advanced PostgreSQL (published, new enrollment)"
      puts "  • Docker Basics (draft)"
      puts
    end
  end
end
