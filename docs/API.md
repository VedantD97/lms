# LMS API Specification

**Version:** 1.0  
**Base URL:** `/api/v1`  
**Format:** JSON  
**Auth:** Bearer JWT access token + HttpOnly refresh cookie

See [ARCHITECTURE.md](./ARCHITECTURE.md) for auth and authorization design.

---

## 1. Conventions

### 1.1 Resource Identifiers

All public resource IDs are **UUIDs**. Integer primary keys are never exposed.

```
GET /api/v1/courses/a1b2c3d4-...
```

### 1.2 Success Response Envelope

```json
{
  "data": { ... } | [ ... ],
  "meta": { "page": 1, "per_page": 20, "total": 142 }
}
```

- `meta` is present on paginated list endpoints only
- Single resources return `{ "data": { ... } }`

### 1.3 Error Response Envelope

```json
{
  "error": {
    "code": "validation_error",
    "message": "Validation failed",
    "details": [
      { "field": "title", "message": "Title can't be blank" }
    ]
  }
}
```

### 1.4 Error Codes

| HTTP | Code | When |
|------|------|------|
| 400 | `parameter_missing` | Required param absent |
| 401 | `unauthorized` | Missing/invalid token |
| 403 | `forbidden` | Authenticated but not permitted |
| 404 | `not_found` | Resource not found |
| 422 | `validation_error` | Model validation failed |
| 422 | `invalid_state` | Business rule violation (e.g. max attempts reached) |
| 429 | `rate_limit_exceeded` | Too many requests (rack-attack throttling) |

### 1.5 Pagination

Query params: `page` (default 1), `per_page` (default 20, max 100)

```json
{
  "data": [ ... ],
  "meta": { "page": 1, "per_page": 20, "total": 142 }
}
```

### 1.6 Filtering & Search

Common query params on list endpoints:

| Param | Example | Description |
|-------|---------|-------------|
| `q` | `?q=ruby` | Full-text search (title, description) |
| `status` | `?status=published` | Filter by status enum |
| `level` | `?level=beginner` | Course level |
| `category` | `?category=web-dev` | Category slug |
| `role` | `?role=instructor` | User role filter (admin) |

### 1.7 Sorting

Default sort is defined per resource (usually `created_at desc` or `position asc`).

Future: `sort=title`, `order=asc|desc`

### 1.8 Request Bodies

Rails-style nested params:

```json
{ "course": { "title": "...", "level": "beginner" } }
{ "question": { "body": "...", "points": 2 } }
{ "option": { "body": "...", "is_correct": true } }
```

### 1.9 Role Namespaces

| Prefix | Required role |
|--------|---------------|
| `/api/v1/auth/*` | Public (some endpoints need auth) |
| `/api/v1/admin/*` | admin or super_admin |
| `/api/v1/instructor/*` | instructor (+ admin override where policy allows) |
| `/api/v1/student/*` | student |

---

## 2. Authentication

| Method | Path | Status | Description |
|--------|------|--------|-------------|
| POST | `/auth/register` | Planned | Student self-registration |
| POST | `/auth/login` | **Implemented** | Returns access_token + user; sets refresh cookie |
| POST | `/auth/refresh` | **Implemented** | Rotate access token via cookie |
| DELETE | `/auth/logout` | **Implemented** | Revoke refresh token |
| GET | `/auth/me` | **Implemented** | Current user + roles |
| POST | `/auth/forgot_password` | **Implemented** | Send reset email |
| POST | `/auth/reset_password` | **Implemented** | Reset with token |

---

## 3. Health & Public

| Method | Path | Status | Description |
|--------|------|--------|-------------|
| GET | `/health` | **Implemented** | Health check |
| GET | `/categories` | **Implemented** | Public category list |

---

## 4. Admin Endpoints

### Users
| Method | Path | Status |
|--------|------|--------|
| GET | `/admin/users?role=instructor` | **Implemented** |

### Categories
| Method | Path | Status |
|--------|------|--------|
| GET | `/admin/categories` | **Implemented** |
| POST | `/admin/categories` | **Implemented** |
| GET | `/admin/categories/:uuid` | **Implemented** |
| PATCH | `/admin/categories/:uuid` | **Implemented** |
| DELETE | `/admin/categories/:uuid` | **Implemented** |

### Courses
| Method | Path | Status |
|--------|------|--------|
| GET | `/admin/courses` | **Implemented** |
| POST | `/admin/courses` | **Implemented** |
| GET | `/admin/courses/:uuid` | **Implemented** |
| PATCH | `/admin/courses/:uuid` | **Implemented** |
| DELETE | `/admin/courses/:uuid` | **Implemented** (archives) |
| POST | `/admin/courses/:uuid/publish` | **Implemented** |
| POST | `/admin/courses/:uuid/unpublish` | **Implemented** |
| POST | `/admin/courses/:uuid/archive` | **Implemented** |
| POST | `/admin/courses/:uuid/instructors` | **Implemented** |
| DELETE | `/admin/courses/:uuid/instructors/:user_uuid` | **Implemented** |

### Enrollments
| Method | Path | Status |
|--------|------|--------|
| GET | `/admin/enrollments` | **Implemented** |
| POST | `/admin/enrollments` | **Implemented** |
| GET | `/admin/enrollments/:uuid` | **Implemented** |
| DELETE | `/admin/enrollments/:uuid` | **Implemented** |

### Quizzes
| Method | Path | Status |
|--------|------|--------|
| GET | `/admin/quizzes` | **Implemented** |
| GET | `/admin/quizzes/:uuid` | **Implemented** |
| GET | `/admin/quizzes/:uuid/statistics` | **Implemented** |

### Certificates
| Method | Path | Status |
|--------|------|--------|
| GET | `/admin/certificates` | **Implemented** |
| GET | `/admin/certificates/:uuid` | **Implemented** |
| POST | `/admin/certificates/:uuid/revoke` | **Implemented** |

### Announcements
| Method | Path | Status |
|--------|------|--------|
| GET | `/admin/announcements` | **Implemented** |
| POST | `/admin/announcements` | **Implemented** |
| GET | `/admin/announcements/:uuid` | **Implemented** |
| PATCH | `/admin/announcements/:uuid` | **Implemented** |
| DELETE | `/admin/announcements/:uuid` | **Implemented** |
| POST | `/admin/announcements/:uuid/publish` | **Implemented** |

### Reviews
| Method | Path | Status |
|--------|------|--------|
| GET | `/admin/reviews` | **Implemented** |
| GET | `/admin/reviews/:uuid` | **Implemented** |
| DELETE | `/admin/reviews/:uuid` | **Implemented** |

### Reports
| Method | Path | Status |
|--------|------|--------|
| GET | `/admin/reports/dashboard` | **Implemented** |
| GET | `/admin/reports/enrollments` | **Implemented** (filters: `from`, `to`, `course_uuid`, `status`) |
| GET | `/admin/reports/course_completion` | **Implemented** |

### Audit logs (super_admin only)
| Method | Path | Status |
|--------|------|--------|
| GET | `/admin/audit_logs` | **Implemented** |
| GET | `/admin/audit_logs/:uuid` | **Implemented** |

Audit logs are recorded for certificate revoke, review deletion, and enrollment drop actions.

### Planned (Phase 14+)
- `/admin/users` CRUD
- `/admin/batches`
- `/admin/reports/*` (additional analytics)

---

## 5. Instructor Endpoints

### Dashboard & Progress
| Method | Path | Status |
|--------|------|--------|
| GET | `/instructor/dashboard` | **Implemented** |
| GET | `/instructor/courses/:uuid/enrollments` | **Implemented** |
| GET | `/instructor/enrollments/:uuid/progress` | **Implemented** |
| GET | `/instructor/submissions/pending` | **Implemented** |

### Courses
| Method | Path | Status |
|--------|------|--------|
| GET | `/instructor/courses` | **Implemented** |
| POST | `/instructor/courses` | **Implemented** |
| GET | `/instructor/courses/:uuid` | **Implemented** |
| PATCH | `/instructor/courses/:uuid` | **Implemented** |
| POST | `/instructor/courses/:uuid/publish` | **Implemented** |
| POST | `/instructor/courses/:uuid/unpublish` | **Implemented** |

### Modules
| Method | Path | Status |
|--------|------|--------|
| GET | `/instructor/courses/:uuid/modules` | **Implemented** |
| POST | `/instructor/courses/:uuid/modules` | **Implemented** |
| PATCH | `/instructor/courses/:uuid/modules/reorder` | **Implemented** |
| PATCH | `/instructor/modules/:uuid` | **Implemented** |
| DELETE | `/instructor/modules/:uuid` | **Implemented** |

### Lessons
| Method | Path | Status |
|--------|------|--------|
| GET | `/instructor/modules/:uuid/lessons` | **Implemented** |
| POST | `/instructor/modules/:uuid/lessons` | **Implemented** |
| PATCH | `/instructor/modules/:uuid/lessons/reorder` | **Implemented** |
| PATCH | `/instructor/lessons/:uuid` | **Implemented** |
| DELETE | `/instructor/lessons/:uuid` | **Implemented** |

### Lesson Resources
| Method | Path | Status |
|--------|------|--------|
| POST | `/instructor/lessons/:uuid/resources` | **Implemented** (multipart) |
| DELETE | `/instructor/resources/:uuid` | **Implemented** |

### Quizzes
| Method | Path | Status |
|--------|------|--------|
| GET | `/instructor/lessons/:uuid/quizzes` | **Implemented** |
| POST | `/instructor/lessons/:uuid/quizzes` | **Implemented** |
| GET | `/instructor/courses/:uuid/quizzes` | **Implemented** |
| POST | `/instructor/courses/:uuid/quizzes` | **Implemented** |
| GET | `/instructor/quizzes/:uuid` | **Implemented** |
| PATCH | `/instructor/quizzes/:uuid` | **Implemented** |
| DELETE | `/instructor/quizzes/:uuid` | **Implemented** |
| POST | `/instructor/quizzes/:uuid/publish` | **Implemented** |
| POST | `/instructor/quizzes/:uuid/unpublish` | **Implemented** |
| GET | `/instructor/quizzes/:uuid/attempts` | **Implemented** |

### Questions & Options
| Method | Path | Status |
|--------|------|--------|
| GET | `/instructor/quizzes/:uuid/questions` | **Implemented** |
| POST | `/instructor/quizzes/:uuid/questions` | **Implemented** |
| PATCH | `/instructor/quizzes/:uuid/questions/reorder` | **Implemented** |
| PATCH | `/instructor/questions/:uuid` | **Implemented** |
| DELETE | `/instructor/questions/:uuid` | **Implemented** |
| POST | `/instructor/questions/:uuid/options` | **Implemented** |
| PATCH | `/instructor/options/:uuid` | **Implemented** |
| DELETE | `/instructor/options/:uuid` | **Implemented** |

### Assignments
| Method | Path | Status |
|--------|------|--------|
| GET | `/instructor/courses/:course_uuid/assignments` | **Implemented** |
| POST | `/instructor/courses/:course_uuid/assignments` | **Implemented** |
| GET | `/instructor/lessons/:lesson_uuid/assignments` | **Implemented** |
| POST | `/instructor/lessons/:lesson_uuid/assignments` | **Implemented** |
| GET | `/instructor/assignments/:uuid` | **Implemented** |
| PATCH | `/instructor/assignments/:uuid` | **Implemented** |
| DELETE | `/instructor/assignments/:uuid` | **Implemented** |
| POST | `/instructor/assignments/:uuid/publish` | **Implemented** |
| POST | `/instructor/assignments/:uuid/unpublish` | **Implemented** |
| GET | `/instructor/assignments/:uuid/submissions` | **Implemented** |
| PATCH | `/instructor/submissions/:uuid/grade` | **Implemented** |

### Announcements
| Method | Path | Status |
|--------|------|--------|
| GET | `/instructor/courses/:course_uuid/announcements` | **Implemented** |
| POST | `/instructor/courses/:course_uuid/announcements` | **Implemented** |
| GET | `/instructor/announcements/:uuid` | **Implemented** |
| PATCH | `/instructor/announcements/:uuid` | **Implemented** |
| DELETE | `/instructor/announcements/:uuid` | **Implemented** |
| POST | `/instructor/announcements/:uuid/publish` | **Implemented** |

---

## 6. Student Endpoints

### Dashboard
| Method | Path | Status |
|--------|------|--------|
| GET | `/student/dashboard` | **Implemented** |

Returns enrollment stats, average progress, certificates, unread notifications, continue-learning items, pending quizzes/assignments, and recent notifications.

### Courses
| Method | Path | Status |
|--------|------|--------|
| GET | `/student/courses` | **Implemented** (catalog) |
| GET | `/student/courses/:uuid` | **Implemented** |
| POST | `/student/courses/:uuid/enroll` | **Implemented** |

### Enrollments & Progress
| Method | Path | Status |
|--------|------|--------|
| GET | `/student/enrollments` | **Implemented** |
| GET | `/student/enrollments/:uuid` | **Implemented** |
| GET | `/student/enrollments/:uuid/lessons/:lesson_uuid` | **Implemented** |
| PATCH | `/student/enrollments/:uuid/lessons/:lesson_uuid/progress` | **Implemented** |
| POST | `/student/enrollments/:uuid/lessons/:lesson_uuid/complete` | **Implemented** |
| GET | `/student/enrollments/:uuid/resources/:resource_uuid/download` | **Implemented** (file stream or external link JSON) |

Enrollment list/detail responses include `continue_learning` (next incomplete lesson) and `progress_summary` (lessons, quizzes, and assignments breakdown) when applicable.

### Quizzes
| Method | Path | Status |
|--------|------|--------|
| GET | `/student/enrollments/:uuid/quizzes` | **Implemented** |
| GET | `/student/enrollments/:uuid/quizzes/:quiz_uuid` | **Implemented** |
| POST | `/student/enrollments/:uuid/quizzes/:quiz_uuid/start` | **Implemented** |
| GET | `/student/quiz_attempts/:uuid` | **Implemented** (no correct answers) |
| PATCH | `/student/quiz_attempts/:uuid/responses` | **Implemented** |
| POST | `/student/quiz_attempts/:uuid/submit` | **Implemented** |
| GET | `/student/quiz_attempts/:uuid/results` | **Implemented** |

### Assignments
| Method | Path | Status |
|--------|------|--------|
| GET | `/student/enrollments/:uuid/assignments` | **Implemented** |
| GET | `/student/enrollments/:uuid/assignments/:assignment_uuid` | **Implemented** |
| POST | `/student/enrollments/:uuid/assignments/:assignment_uuid/submit` | **Implemented** |

### Certificates
| Method | Path | Status |
|--------|------|--------|
| GET | `/student/certificates` | **Implemented** |
| GET | `/student/certificates/:uuid` | **Implemented** |

Enrollment responses include an active `certificate` summary when the course is completed.

### Notifications
| Method | Path | Status |
|--------|------|--------|
| GET | `/student/notifications` | **Implemented** |
| GET | `/student/notifications/unread_count` | **Implemented** |
| GET | `/student/notifications/:uuid` | **Implemented** |
| PATCH | `/student/notifications/:uuid/read` | **Implemented** |
| POST | `/student/notifications/read_all` | **Implemented** |

### Announcements
| Method | Path | Status |
|--------|------|--------|
| GET | `/student/announcements` | **Implemented** (published global + enrolled course) |

### Reviews
| Method | Path | Status |
|--------|------|--------|
| GET | `/student/courses/:uuid/reviews` | **Implemented** (includes `average_rating`, `review_count` in meta) |
| POST | `/student/courses/:uuid/reviews` | **Implemented** (enrolled students only; one per user/course) |
| PATCH | `/student/reviews/:uuid` | **Implemented** (own review) |
| DELETE | `/student/reviews/:uuid` | **Implemented** (own review) |

Course detail includes `average_rating`, `review_count`, and `my_review` when authenticated.

---

## 7. Serializer Field Visibility

| Field | Admin | Instructor | Student |
|-------|-------|------------|---------|
| `is_correct` on options | Yes | Yes | **Never before submit** |
| Quiz correct answers | Yes | Yes | Only after submit if configured |
| Other students' attempts | Yes | Own courses | **Never** |
| `password_digest` | Never | Never | Never |

Student quiz attempt serializer includes questions and options **without** `is_correct`. Results serializer may include correct answers only when `show_correct_answers = after_submit` and attempt is submitted.

---

## 8. Example Flows

### 8.1 Login

```http
POST /api/v1/auth/login
Content-Type: application/json

{ "auth": { "email": "student@example.com", "password": "password123" } }
```

```json
{
  "data": {
    "access_token": "eyJ...",
    "token_type": "Bearer",
    "user": { "uuid": "...", "email": "...", "roles": ["student"] }
  }
}
```

### 8.2 Take Quiz (Student)

```
1. POST .../enrollments/:uuid/quizzes/:quiz_uuid/start  → attempt created
2. PATCH .../quiz_attempts/:uuid/responses              → save answers
3. POST .../quiz_attempts/:uuid/submit                  → scored server-side
4. GET .../quiz_attempts/:uuid/results                  → view results
```

### 8.3 Create Course (Instructor)

```http
POST /api/v1/instructor/courses
Authorization: Bearer eyJ...

{ "course": { "title": "Intro to Ruby", "level": "beginner" } }
```

---

## 9. Versioning Strategy

- Current version: `v1`
- Breaking changes require `v2` namespace
- Additive changes (new fields, new endpoints) are allowed within `v1`
- Deprecation: announce in changelog, maintain for one release cycle

---

## 10. Future Endpoints (Not Yet Implemented)

Documented here for planning; do not implement until their phase begins.

```
# Reports (Phase 13) — Implemented
GET    /admin/reports/dashboard
GET    /admin/reports/enrollments
GET    /admin/reports/course_completion
GET    /admin/audit_logs
```
