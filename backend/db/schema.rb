# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_09_05_190001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "announcements", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "author_id", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.integer "audience", default: 0, null: false
    t.bigint "course_id"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["audience"], name: "index_announcements_on_audience"
    t.index ["author_id"], name: "index_announcements_on_author_id"
    t.index ["course_id"], name: "index_announcements_on_course_id"
    t.index ["published_at"], name: "index_announcements_on_published_at"
    t.index ["uuid"], name: "index_announcements_on_uuid", unique: true
    t.check_constraint "audience >= 0 AND audience <= 1", name: "announcements_audience_check"
  end

  create_table "assignment_submissions", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "assignment_id", null: false
    t.bigint "enrollment_id", null: false
    t.text "body"
    t.datetime "submitted_at"
    t.boolean "late", default: false, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id", "enrollment_id"], name: "index_assignment_submissions_on_assignment_and_enrollment", unique: true
    t.index ["assignment_id"], name: "index_assignment_submissions_on_assignment_id"
    t.index ["enrollment_id"], name: "index_assignment_submissions_on_enrollment_id"
    t.index ["status"], name: "index_assignment_submissions_on_status"
    t.index ["uuid"], name: "index_assignment_submissions_on_uuid", unique: true
    t.check_constraint "status >= 0 AND status <= 1", name: "assignment_submissions_status_check"
  end

  create_table "assignments", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "course_id", null: false
    t.bigint "lesson_id"
    t.string "title", null: false
    t.text "description"
    t.datetime "due_at"
    t.decimal "max_points", precision: 8, scale: 2, default: "100.0", null: false
    t.decimal "passing_score", precision: 5, scale: 2, default: "70.0", null: false
    t.boolean "allow_late", default: false, null: false
    t.boolean "allow_resubmit", default: true, null: false
    t.boolean "required_for_completion", default: true, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_assignments_on_course_id"
    t.index ["due_at"], name: "index_assignments_on_due_at"
    t.index ["lesson_id"], name: "index_assignments_on_lesson_id"
    t.index ["required_for_completion"], name: "index_assignments_on_required_for_completion"
    t.index ["status"], name: "index_assignments_on_status"
    t.index ["uuid"], name: "index_assignments_on_uuid", unique: true
    t.check_constraint "max_points >= 0::numeric", name: "assignments_max_points_check"
    t.check_constraint "passing_score >= 0::numeric AND passing_score <= 100::numeric", name: "assignments_passing_score_check"
    t.check_constraint "status >= 0 AND status <= 1", name: "assignments_status_check"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "actor_id", null: false
    t.string "action", null: false
    t.string "auditable_type"
    t.bigint "auditable_id"
    t.jsonb "metadata", default: {}, null: false
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["actor_id"], name: "index_audit_logs_on_actor_id"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["uuid"], name: "index_audit_logs_on_uuid", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.bigint "parent_id"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["position"], name: "index_categories_on_position"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
    t.index ["uuid"], name: "index_categories_on_uuid", unique: true
  end

  create_table "certificates", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "enrollment_id", null: false
    t.string "certificate_number", null: false
    t.datetime "issued_at", null: false
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["certificate_number"], name: "index_certificates_on_certificate_number", unique: true
    t.index ["enrollment_id"], name: "index_certificates_on_enrollment_id"
    t.index ["revoked_at"], name: "index_certificates_on_revoked_at"
    t.index ["uuid"], name: "index_certificates_on_uuid", unique: true
  end

  create_table "course_categories", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_course_categories_on_category_id"
    t.index ["course_id", "category_id"], name: "index_course_categories_on_course_id_and_category_id", unique: true
    t.index ["course_id"], name: "index_course_categories_on_course_id"
  end

  create_table "course_instructors", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "user_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "user_id"], name: "index_course_instructors_on_course_id_and_user_id", unique: true
    t.index ["course_id"], name: "index_course_instructors_on_course_id"
    t.index ["user_id"], name: "index_course_instructors_on_user_id"
    t.check_constraint "role >= 0 AND role <= 1", name: "course_instructors_role_check"
  end

  create_table "course_modules", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "course_id", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "position"], name: "index_course_modules_on_course_id_and_position"
    t.index ["course_id"], name: "index_course_modules_on_course_id"
    t.index ["status"], name: "index_course_modules_on_status"
    t.index ["uuid"], name: "index_course_modules_on_uuid", unique: true
    t.check_constraint "status >= 0 AND status <= 1", name: "course_modules_status_check"
  end

  create_table "courses", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "title", null: false
    t.string "slug", null: false
    t.text "description"
    t.string "short_description"
    t.integer "status", default: 0, null: false
    t.integer "level", default: 0, null: false
    t.integer "duration_minutes"
    t.datetime "published_at"
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_courses_on_created_by_id"
    t.index ["slug"], name: "index_courses_on_slug", unique: true
    t.index ["status", "published_at"], name: "index_courses_on_status_and_published_at"
    t.index ["status"], name: "index_courses_on_status"
    t.index ["uuid"], name: "index_courses_on_uuid", unique: true
    t.check_constraint "level >= 0 AND level <= 2", name: "courses_level_check"
    t.check_constraint "status >= 0 AND status <= 2", name: "courses_status_check"
  end

  create_table "enrollments", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "enrolled_at", null: false
    t.datetime "completed_at"
    t.decimal "progress_percent", precision: 5, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["status"], name: "index_enrollments_on_status"
    t.index ["user_id", "course_id"], name: "index_enrollments_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
    t.index ["uuid"], name: "index_enrollments_on_uuid", unique: true
    t.check_constraint "progress_percent >= 0::numeric AND progress_percent <= 100::numeric", name: "enrollments_progress_percent_check"
    t.check_constraint "status >= 0 AND status <= 3", name: "enrollments_status_check"
  end

  create_table "grades", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "gradable_type", null: false
    t.bigint "gradable_id", null: false
    t.decimal "points", precision: 8, scale: 2, null: false
    t.decimal "percentage", precision: 5, scale: 2, null: false
    t.boolean "passed", default: false, null: false
    t.text "feedback"
    t.bigint "graded_by_id", null: false
    t.datetime "graded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gradable_type", "gradable_id"], name: "index_grades_on_gradable"
    t.index ["graded_by_id"], name: "index_grades_on_graded_by_id"
    t.index ["uuid"], name: "index_grades_on_uuid", unique: true
    t.check_constraint "percentage >= 0::numeric AND percentage <= 100::numeric", name: "grades_percentage_check"
    t.check_constraint "points >= 0::numeric", name: "grades_points_check"
  end

  create_table "lesson_progresses", force: :cascade do |t|
    t.bigint "enrollment_id", null: false
    t.bigint "lesson_id", null: false
    t.integer "status", default: 0, null: false
    t.decimal "progress_percent", precision: 5, scale: 2, default: "0.0", null: false
    t.integer "last_position_seconds", default: 0, null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id", "lesson_id"], name: "index_lesson_progresses_on_enrollment_id_and_lesson_id", unique: true
    t.index ["enrollment_id"], name: "index_lesson_progresses_on_enrollment_id"
    t.index ["lesson_id"], name: "index_lesson_progresses_on_lesson_id"
    t.index ["status"], name: "index_lesson_progresses_on_status"
    t.check_constraint "last_position_seconds >= 0", name: "lesson_progresses_last_position_seconds_check"
    t.check_constraint "progress_percent >= 0::numeric AND progress_percent <= 100::numeric", name: "lesson_progresses_progress_percent_check"
    t.check_constraint "status >= 0 AND status <= 2", name: "lesson_progresses_status_check"
  end

  create_table "lesson_resources", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "lesson_id", null: false
    t.integer "resource_type", default: 0, null: false
    t.string "title", null: false
    t.string "external_url"
    t.integer "position", default: 0, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id", "position"], name: "index_lesson_resources_on_lesson_id_and_position"
    t.index ["lesson_id"], name: "index_lesson_resources_on_lesson_id"
    t.index ["uuid"], name: "index_lesson_resources_on_uuid", unique: true
    t.check_constraint "resource_type >= 0 AND resource_type <= 4", name: "lesson_resources_resource_type_check"
  end

  create_table "lessons", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "course_module_id", null: false
    t.string "title", null: false
    t.text "content"
    t.integer "content_type", default: 2, null: false
    t.integer "duration_seconds"
    t.integer "position", default: 0, null: false
    t.boolean "is_preview", default: false, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "required_for_completion", default: true, null: false
    t.index ["course_module_id", "position"], name: "index_lessons_on_course_module_id_and_position"
    t.index ["course_module_id"], name: "index_lessons_on_course_module_id"
    t.index ["is_preview"], name: "index_lessons_on_is_preview"
    t.index ["required_for_completion"], name: "index_lessons_on_required_for_completion"
    t.index ["status"], name: "index_lessons_on_status"
    t.index ["uuid"], name: "index_lessons_on_uuid", unique: true
    t.check_constraint "content_type >= 0 AND content_type <= 3", name: "lessons_content_type_check"
    t.check_constraint "status >= 0 AND status <= 1", name: "lessons_status_check"
  end

  create_table "notifications", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "user_id", null: false
    t.integer "notification_type", default: 0, null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
    t.index ["uuid"], name: "index_notifications_on_uuid", unique: true
    t.check_constraint "notification_type >= 0 AND notification_type <= 3", name: "notifications_notification_type_check"
  end

  create_table "password_reset_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_password_reset_tokens_on_expires_at"
    t.index ["token_digest"], name: "index_password_reset_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "question_options", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "question_id", null: false
    t.text "body", null: false
    t.boolean "is_correct", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "position"], name: "index_question_options_on_question_id_and_position"
    t.index ["question_id"], name: "index_question_options_on_question_id"
    t.index ["uuid"], name: "index_question_options_on_uuid", unique: true
  end

  create_table "questions", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "quiz_id", null: false
    t.integer "question_type", default: 0, null: false
    t.text "body", null: false
    t.decimal "points", precision: 5, scale: 2, default: "1.0", null: false
    t.integer "position", default: 0, null: false
    t.text "explanation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id", "position"], name: "index_questions_on_quiz_id_and_position"
    t.index ["quiz_id"], name: "index_questions_on_quiz_id"
    t.index ["uuid"], name: "index_questions_on_uuid", unique: true
    t.check_constraint "points >= 0::numeric", name: "questions_points_check"
    t.check_constraint "question_type >= 0 AND question_type <= 2", name: "questions_question_type_check"
  end

  create_table "quiz_attempts", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "quiz_id", null: false
    t.bigint "enrollment_id", null: false
    t.integer "attempt_number", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.decimal "score", precision: 8, scale: 2
    t.decimal "max_score", precision: 8, scale: 2
    t.decimal "percentage", precision: 5, scale: 2
    t.boolean "passed"
    t.datetime "started_at", null: false
    t.datetime "submitted_at"
    t.datetime "expires_at"
    t.integer "time_spent_seconds"
    t.jsonb "question_order", default: [], null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id", "status"], name: "index_quiz_attempts_on_enrollment_id_and_status"
    t.index ["enrollment_id"], name: "index_quiz_attempts_on_enrollment_id"
    t.index ["quiz_id", "enrollment_id", "attempt_number"], name: "idx_on_quiz_id_enrollment_id_attempt_number_8fda0e2faf", unique: true
    t.index ["quiz_id"], name: "index_quiz_attempts_on_quiz_id"
    t.index ["uuid"], name: "index_quiz_attempts_on_uuid", unique: true
    t.check_constraint "attempt_number >= 1", name: "quiz_attempts_attempt_number_check"
    t.check_constraint "status >= 0 AND status <= 2", name: "quiz_attempts_status_check"
  end

  create_table "quiz_responses", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "quiz_attempt_id", null: false
    t.bigint "question_id", null: false
    t.jsonb "selected_option_uuids", default: [], null: false
    t.boolean "is_correct"
    t.decimal "points_awarded", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_quiz_responses_on_question_id"
    t.index ["quiz_attempt_id", "question_id"], name: "index_quiz_responses_on_quiz_attempt_id_and_question_id", unique: true
    t.index ["quiz_attempt_id"], name: "index_quiz_responses_on_quiz_attempt_id"
    t.index ["uuid"], name: "index_quiz_responses_on_uuid", unique: true
  end

  create_table "quizzes", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "course_id", null: false
    t.bigint "lesson_id"
    t.string "title", null: false
    t.text "description"
    t.integer "time_limit_minutes"
    t.decimal "passing_score", precision: 5, scale: 2, default: "70.0", null: false
    t.integer "max_attempts", default: 1, null: false
    t.boolean "shuffle_questions", default: false, null: false
    t.boolean "shuffle_answers", default: false, null: false
    t.integer "status", default: 0, null: false
    t.integer "show_correct_answers", default: 0, null: false
    t.datetime "available_from"
    t.datetime "available_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "required_for_completion", default: true, null: false
    t.index ["course_id"], name: "index_quizzes_on_course_id"
    t.index ["lesson_id"], name: "index_quizzes_on_lesson_id"
    t.index ["required_for_completion"], name: "index_quizzes_on_required_for_completion"
    t.index ["status"], name: "index_quizzes_on_status"
    t.index ["uuid"], name: "index_quizzes_on_uuid", unique: true
    t.check_constraint "max_attempts >= 0", name: "quizzes_max_attempts_check"
    t.check_constraint "passing_score >= 0::numeric AND passing_score <= 100::numeric", name: "quizzes_passing_score_check"
    t.check_constraint "show_correct_answers >= 0 AND show_correct_answers <= 1", name: "quizzes_show_correct_answers_check"
    t.check_constraint "status >= 0 AND status <= 1", name: "quizzes_status_check"
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_refresh_tokens_on_expires_at"
    t.index ["revoked_at"], name: "index_refresh_tokens_on_revoked_at"
    t.index ["token_digest"], name: "index_refresh_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "course_id", null: false
    t.bigint "user_id", null: false
    t.integer "rating", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "user_id"], name: "index_reviews_on_course_id_and_user_id", unique: true
    t.index ["course_id"], name: "index_reviews_on_course_id"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["user_id"], name: "index_reviews_on_user_id"
    t.index ["uuid"], name: "index_reviews_on_uuid", unique: true
    t.check_constraint "rating >= 1 AND rating <= 5", name: "reviews_rating_check"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "email_verified_at"
    t.datetime "last_sign_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.index ["status"], name: "index_users_on_status"
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "announcements", "courses"
  add_foreign_key "announcements", "users", column: "author_id"
  add_foreign_key "assignment_submissions", "assignments"
  add_foreign_key "assignment_submissions", "enrollments"
  add_foreign_key "assignments", "courses"
  add_foreign_key "assignments", "lessons"
  add_foreign_key "audit_logs", "users", column: "actor_id"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "certificates", "enrollments"
  add_foreign_key "course_categories", "categories"
  add_foreign_key "course_categories", "courses"
  add_foreign_key "course_instructors", "courses"
  add_foreign_key "course_instructors", "users"
  add_foreign_key "course_modules", "courses"
  add_foreign_key "courses", "users", column: "created_by_id"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users"
  add_foreign_key "grades", "users", column: "graded_by_id"
  add_foreign_key "lesson_progresses", "enrollments"
  add_foreign_key "lesson_progresses", "lessons"
  add_foreign_key "lesson_resources", "lessons"
  add_foreign_key "lessons", "course_modules"
  add_foreign_key "notifications", "users"
  add_foreign_key "password_reset_tokens", "users"
  add_foreign_key "question_options", "questions"
  add_foreign_key "questions", "quizzes"
  add_foreign_key "quiz_attempts", "enrollments"
  add_foreign_key "quiz_attempts", "quizzes"
  add_foreign_key "quiz_responses", "questions"
  add_foreign_key "quiz_responses", "quiz_attempts"
  add_foreign_key "quizzes", "courses"
  add_foreign_key "quizzes", "lessons"
  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "reviews", "courses"
  add_foreign_key "reviews", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
