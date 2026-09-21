# LMS Database Design

**Version:** 1.0  
**Engine:** PostgreSQL 16+  
**Extensions:** `pgcrypto` (UUID generation)

See [ARCHITECTURE.md](./ARCHITECTURE.md) for domain overview.

---

## 1. Design Principles

1. **UUIDs** for all externally exposed resource identifiers
2. **Integer PKs** internally for join performance
3. **Foreign keys** on all associations
4. **Check constraints** on enums and numeric ranges
5. **Unique constraints** to prevent invalid states (duplicate enrollments, duplicate quiz responses)
6. **NOT NULL** on required fields
7. **Timestamps** (`created_at`, `updated_at`) on all tables
8. **Soft delete** only where justified (courses use `archived` status, not `deleted_at`)
9. Prevent invalid states at DB level whenever possible

---

## 2. Entity Relationship Diagram

```
┌─────────┐       ┌───────────┐       ┌──────┐
│  User   │──────<│ UserRole  │>──────│ Role │
└────┬────┘       └───────────┘       └──────┘
     │
     │ created_by
     ▼
┌─────────┐       ┌─────────────────┐       ┌──────────┐
│ Course  │──────<│ CourseInstructor│>──────│ User     │
└────┬────┘       └─────────────────┘       └──────────┘
     │
     ├──< CourseCategory >── Category (self-referential parent)
     │
     ├──< CourseModule >── Lesson ──< LessonResource
     │                         │
     │                         └──< Quiz ──< Question ──< QuestionOption
     │
     ├──< Enrollment >── User
     │       │
     │       ├──< LessonProgress >── Lesson
     │       │
     │       └──< QuizAttempt >── Quiz
     │               │
     │               └──< QuizResponse >── Question
     │
     └──< Quiz (optional lesson_id)

Auth tables: RefreshToken, PasswordResetToken
Storage: active_storage_blobs, active_storage_attachments
```

### Planned (not yet migrated)

```
Batch ──< Enrollment
Assignment ──< AssignmentSubmission ── Grade
Certificate
Announcement
Notification
Review
AuditLog
```

---

## 3. Implemented Tables

### 3.1 users

| Column | Type | Constraints |
|--------|------|-------------|
| id | bigint | PK |
| uuid | uuid | NOT NULL, UNIQUE, default gen_random_uuid() |
| email | string | NOT NULL, UNIQUE (case-insensitive index) |
| password_digest | string | NOT NULL |
| first_name | string | NOT NULL |
| last_name | string | NOT NULL |
| status | integer | NOT NULL, check 0–2 |
| email_verified_at | datetime | |
| last_sign_in_at | datetime | |

### 3.2 roles / user_roles

**roles:** `name` UNIQUE (super_admin, admin, instructor, student)

**user_roles:** UNIQUE(user_id, role_id)

### 3.3 categories

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| name, slug | slug UNIQUE |
| parent_id | Self-referential FK (nullable) |
| position | Ordering |

### 3.4 courses

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| title, slug | slug UNIQUE |
| status | enum: draft(0), published(1), archived(2) |
| level | enum: beginner(0), intermediate(1), advanced(2) |
| published_at | Set on publish |
| created_by_id | FK → users |

Check constraints on status, level.

### 3.5 course_categories

UNIQUE(course_id, category_id)

### 3.6 course_instructors

| Column | Notes |
|--------|-------|
| course_id, user_id | UNIQUE together |
| role | enum: lead(0), assistant(1) |

### 3.7 course_modules

Table name: `course_modules` (model: `CourseModule`)

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| course_id | FK |
| position | Ordering within course |
| status | draft / published |

### 3.8 lessons

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| course_module_id | FK |
| content_type | video, document, text, mixed |
| position | Ordering within module |
| is_preview | Boolean — accessible without enrollment |
| required_for_completion | Boolean, default true (auto false for preview lessons) |
| status | draft / published |

### 3.9 lesson_resources

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| lesson_id | FK |
| resource_type | video, pdf, document, image, link |
| external_url | For link-type resources |
| metadata | jsonb |
| position | Ordering |

Files attached via Active Storage on the record when not a link.

### 3.10 enrollments

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| user_id, course_id | **UNIQUE together** — prevents duplicate enrollment |
| status | active, completed, dropped, expired |
| enrolled_at | NOT NULL |
| progress_percent | 0–100, computed by service |

**Concurrency:** Unique index on (user_id, course_id) prevents duplicate enrollments under concurrent requests.

### 3.11 lesson_progresses

| Column | Notes |
|--------|-------|
| enrollment_id, lesson_id | **UNIQUE together** |
| status | not_started, in_progress, completed |
| progress_percent | 0–100 |
| last_position_seconds | Video resume position |

Validation: lesson must belong to enrolled course (application-level + service).

### 3.12 quizzes

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| course_id | FK, NOT NULL |
| lesson_id | FK, nullable |
| passing_score | 0–100 (percentage) |
| max_attempts | 0 = unlimited |
| time_limit_minutes | nullable |
| shuffle_questions, shuffle_answers | boolean |
| show_correct_answers | never(0), after_submit(1) |
| available_from, available_until | Availability window |
| required_for_completion | boolean, default true |

### 3.13 questions

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| quiz_id | FK |
| question_type | single_choice(0), multiple_choice(1), true_false(2) |
| points | Marks for this question |
| position | Ordering |
| explanation | Shown after submit if allowed |

### 3.14 question_options

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| question_id | FK |
| body | Option text |
| is_correct | **Never exposed to students pre-submit** |
| position | Ordering |

True/false questions auto-create two options on creation.

### 3.15 quiz_attempts

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| quiz_id, enrollment_id | FK |
| attempt_number | **UNIQUE(quiz_id, enrollment_id, attempt_number)** |
| status | in_progress(0), submitted(1), expired(2) |
| score, max_score, percentage, passed | Set on submit |
| started_at | NOT NULL |
| expires_at | Set from time_limit_minutes |
| question_order | jsonb — shuffled UUID array |
| metadata | jsonb — e.g. shuffle_answers flag |

**Duplicate submission prevention:** Status transition to `submitted` is one-way; service rejects re-submit.

**Multiple attempts:** attempt_number increments; max_attempts checked in StartAttempt service.

### 3.16 quiz_responses

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| quiz_attempt_id, question_id | **UNIQUE together** |
| selected_option_uuids | jsonb array |
| is_correct, points_awarded | Set on scoring |

One response per question per attempt enforced by unique index.

### 3.17 assignments

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| course_id | FK, NOT NULL |
| lesson_id | FK, nullable |
| title | NOT NULL |
| description | Instructions |
| due_at | Optional deadline |
| max_points | Default 100 |
| passing_score | 0–100 percentage |
| allow_late | Boolean |
| allow_resubmit | Boolean — resubmit after failed grade |
| required_for_completion | Boolean, default true |
| status | draft / published |

### 3.18 assignment_submissions

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| assignment_id, enrollment_id | **UNIQUE together** |
| body | Student submission text |
| submitted_at | Set on submit |
| late | Boolean |
| status | submitted, graded |

### 3.19 grades

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| gradable_type, gradable_id | Polymorphic (AssignmentSubmission) |
| points, percentage, passed | Set on grading |
| feedback | Instructor feedback |
| graded_by_id, graded_at | Grader audit |

### 3.20 certificates

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| enrollment_id | FK, **UNIQUE** — one certificate per enrollment |
| certificate_number | Unique human-readable ID |
| issued_at | NOT NULL |
| revoked_at | Set when admin revokes |

Auto-issued by `Certificates::IssueCertificate` when enrollment becomes completed.

### 3.21 announcements

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| author_id | FK to users |
| title, body | Content |
| audience | global(0), course(1) |
| course_id | FK, nullable (required for course audience) |
| published_at | null = draft |

Publishing notifies targeted students via in-app notifications.

### 3.22 notifications

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| user_id | FK |
| notification_type | assignment_graded, course_completed, certificate_issued, announcement |
| payload | jsonb — title, body, related UUIDs |
| read_at | null = unread |

### 3.23 reviews

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| course_id | FK to courses |
| user_id | FK to users |
| rating | Integer 1–5 (CHECK constraint) |
| body | Optional text |

UNIQUE(course_id, user_id) — one review per enrolled student per course. Course `average_rating` and `review_count` are computed from associated reviews.

### 3.24 audit_logs

| Column | Notes |
|--------|-------|
| uuid | Public ID |
| actor_id | FK to users |
| action | Event name (e.g. `certificate.revoked`, `review.deleted`) |
| auditable_type, auditable_id | Polymorphic reference (optional) |
| metadata | jsonb — event payload (API exposes as `changes`) |
| ip_address | Request IP when recorded |

Written by `AuditLogs::Record` on sensitive admin actions. Readable by super_admin only.

### 3.25 Auth tokens

**refresh_tokens:** token_digest UNIQUE, expires_at, revoked_at, user_id FK

**password_reset_tokens:** token_digest UNIQUE, expires_at, used_at, user_id FK

---

## 4. Indexes Summary

| Table | Index | Purpose |
|-------|-------|---------|
| users | lower(email) UNIQUE | Case-insensitive login |
| courses | (status, published_at) | Catalog queries |
| enrollments | (user_id, course_id) UNIQUE | Duplicate prevention |
| quiz_attempts | (quiz_id, enrollment_id, attempt_number) UNIQUE | Attempt tracking |
| assignment_submissions | (assignment_id, enrollment_id) UNIQUE | One submission per enrollment |
| grades | (gradable_type, gradable_id) UNIQUE | One grade per gradable |
| certificates | enrollment_id UNIQUE | One certificate per enrollment |
| reviews | (course_id, user_id) UNIQUE | One review per user per course |
| audit_logs | created_at | Audit trail queries |
| All public tables | uuid UNIQUE | API lookups |

---

## 5. Planned Tables (Phase 14+)

### batches
```
uuid, name, course_id, start_date, end_date, max_students, status
```

---

## 6. Data Integrity Rules

| Rule | Enforcement |
|------|-------------|
| No duplicate enrollment | UNIQUE(user_id, course_id) |
| No duplicate quiz response | UNIQUE(quiz_attempt_id, question_id) |
| No duplicate attempt number | UNIQUE(quiz_id, enrollment_id, attempt_number) |
| Valid progress range | CHECK 0–100 on progress_percent |
| Valid passing score | CHECK 0–100 on quizzes.passing_score |
| Lesson belongs to enrolled course | Application validation in LessonProgress |
| Quiz lesson same course | Application validation in Quiz model |
| Assignment lesson same course | Application validation in Assignment model |
| One submission per enrollment per assignment | UNIQUE(assignment_id, enrollment_id) |
| One in_progress attempt | Application service (StartAttempt) |

---

## 7. Migration Guidelines

1. One concern per migration file
2. Always add foreign keys in same migration as table creation
3. Add check constraints for enums
4. Prefer reversible migrations (`change` with `up`/`down` when needed)
5. Never edit applied migrations — create new ones
6. Run `bin/rails db:migrate` and full test suite after each migration
7. Update this document when schema changes

---

## 8. Naming Conventions

| Concept | Table | Model |
|---------|-------|-------|
| Course module | `course_modules` | `CourseModule` |
| Question option | `question_options` | `QuestionOption` |
| Quiz response | `quiz_responses` | `QuizResponse` |

Avoid Ruby reserved words (`Module`, `Class`) in model names.
