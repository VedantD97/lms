# LMS System Architecture

**Version:** 2.0  
**Status:** Living document — source of truth for all implementation  
**Last updated:** 2026-09-05

---

## Document Map

| Document | Purpose |
|----------|---------|
| [ARCHITECTURE.md](./ARCHITECTURE.md) | System design, decisions, roadmap (this file) |
| [DATABASE.md](./DATABASE.md) | ERD, tables, constraints, indexes |
| [API.md](./API.md) | REST endpoints, envelopes, pagination, errors |
| [DEVELOPMENT.md](./DEVELOPMENT.md) | Setup, workflow, standards, testing |
| [DEPLOYMENT.md](./DEPLOYMENT.md) | Production Docker Compose and Kamal deployment |

---

## 1. Repository Status

> **Important:** This repository is **not empty**. Phases 0–8 are partially or fully implemented. Do not treat this as a greenfield project without inspecting existing code.

| Phase | Scope | Status |
|-------|-------|--------|
| 0 | Project setup, Docker, docs | **Done** |
| 1 | Rails API, PostgreSQL, auth | **Done** |
| 2 | Users, roles, authorization | **Done** |
| 3 | Courses, categories | **Done** |
| 4 | Modules, lessons, resources | **Done** |
| 5 | Enrollment | **Done** (batches not yet) |
| 6 | Student learning experience | **Done** (My Courses dashboard, lesson viewer, continue learning, authorized resource download) |
| 7 | Progress tracking | **Done** (lessons + required quizzes, deterministic recalculation, progress summary) |
| 8 | Quizzes | **Done** (core flow; batch assignment not yet) |
| 9 | Assignments | **Done** (submit, grade, progress integration) |
| 10 | Certificates | **Done** (auto-issue on completion, admin revoke) |
| 11 | Notifications & announcements | **Done** (in-app notifications, global/course announcements) |
| 12 | Reviews | **Done** (student ratings, course averages, admin moderation) |
| 13 | Admin dashboard & reports | **Done** (dashboard summary, enrollment/completion reports, audit logs) |
| 14 | Instructor dashboard | **Done** (overview, students, grading queue, course progress) |
| 15 | Student dashboard | **Done** (overview, continue learning, pending actions, notifications) |
| 16 | Security & performance | **Done** (rate limiting, response caching, upload validation, security headers) |
| 17 | Testing & hardening | **Done** (coverage gates, CI expansion, smoke/load tests, auth integration tests) |
| 18 | Docker & deployment | **Done** (production compose, Kamal config, Caddy proxy, deployment docs) |

**Current test coverage:** 185 backend RSpec examples, 25 frontend Vitest tests. Backend line coverage ≥ 75% (SimpleCov).

---

## 2. High-Level Architecture

Decoupled monolith: **Rails 8 JSON API** + **React SPA**, communicating over versioned REST JSON.

```
Browser (React + Vite + TypeScript)
        │  HTTPS  /api/v1/*
        ▼
Reverse Proxy (Nginx/Caddy in production)
        │
   ┌────┴────┐
   ▼         ▼
Rails API   Static SPA (Vite build)
   │
   ├── PostgreSQL (primary data store)
   ├── Active Storage (local dev / S3 prod)
   └── Solid Queue (background jobs; Redis optional at scale)
```

### 2.1 Layer Responsibilities

| Layer | Responsibility |
|-------|----------------|
| **Controllers** | HTTP: params, auth context, status codes, delegate to services |
| **Policies (Pundit)** | Authorization — who can do what on which record |
| **Services** | Multi-step workflows (enroll, grade quiz, recalculate progress) |
| **Serializers (Alba)** | JSON output; role-specific field visibility |
| **Models** | Validations, associations, scopes — no orchestration |
| **Jobs** | Async: notifications, certificates, video processing |
| **Frontend features** | `api/` + `hooks/` + pages; no API calls in random components |

### 2.2 Cross-Cutting Conventions

- All APIs under `/api/v1/`
- Public resource IDs are **UUIDs** (never expose integer PKs)
- Single-tenant by default; schema allows future `organizations` table
- Standard JSON envelopes (see [API.md](./API.md))
- Phase-by-phase delivery — never implement the entire LMS in one step

---

## 3. Technology Stack

### Backend
- Ruby 3.4+, Rails 8 (API-only), PostgreSQL, RSpec, RuboCop, Brakeman
- Pundit, Alba, Pagy, JWT + HttpOnly refresh cookie, Active Storage, Solid Queue

### Frontend
- React 19, TypeScript (strict), Vite, React Router, TanStack Query
- React Hook Form + Zod, Tailwind CSS, Vitest, React Testing Library

### Infrastructure
- Docker Compose (dev): PostgreSQL, backend, frontend
- Production: separate API + static frontend containers, S3-compatible storage

---

## 4. Authentication Architecture

### Decision: JWT access token (in memory) + HttpOnly refresh cookie

| Approach | Chosen? | Rationale |
|----------|---------|-----------|
| HttpOnly refresh cookie + short-lived JWT | **Yes** | Refresh token not accessible to JS (XSS-resistant); access token in memory for API calls |
| JWT-only in localStorage | No | Vulnerable to XSS token theft |
| Server-side sessions only | No | Harder for SPA + mobile later |

### Flow

```
POST /api/v1/auth/login
  → Returns { access_token, user } in JSON
  → Sets HttpOnly refresh_token cookie

API request with Bearer access_token
  → 401 if expired
  → POST /api/v1/auth/refresh (cookie sent automatically)
  → New access_token returned
  → Original request retried
```

### Password Security
- `bcrypt` via `has_secure_password`
- Password reset via single-use tokens with expiry
- Never expose `password_digest` or tokens in API responses

---

## 5. Authorization Architecture

### Roles (hierarchy)

```
SUPER_ADMIN > ADMIN > INSTRUCTOR > STUDENT
```

Implemented via `roles` + `user_roles` join table. Users may hold multiple roles; highest role determines default dashboard redirect.

### Policy Pattern (Pundit)

Every controller action calls `authorize` or uses `policy_scope`. Policies live in `app/policies/`.

**Non-negotiable rules:**

| Actor | Must NEVER |
|-------|------------|
| Student | Modify courses, view others' quiz attempts/grades, access admin/instructor APIs |
| Instructor | Modify another instructor's courses, access admin APIs |
| Admin | — (scoped by role; super_admin for audit logs) |

### Namespace Isolation

Controllers are namespaced by role:

```
/api/v1/admin/*       → require_admin!
/api/v1/instructor/*  → require_instructor!
/api/v1/student/*     → require_student!
/api/v1/auth/*        → public (with auth where needed)
```

---

## 6. Backend Structure

```
backend/
├── app/
│   ├── controllers/api/v1/
│   │   ├── admin/
│   │   ├── instructor/
│   │   ├── student/
│   │   └── auth/
│   ├── models/ + concerns/
│   ├── policies/
│   ├── serializers/api/v1/
│   ├── services/          # Enrollments::, Courses::, Quizzes::, Progress::, Auth::
│   └── jobs/
├── config/routes.rb
├── db/migrate/
└── spec/
```

**Service object rule:** Use services for multi-step workflows. Do not create services for trivial single-model CRUD.

---

## 7. Frontend Structure

```
frontend/src/
├── app/                  # App shell, providers (future)
├── components/           # Shared UI (Button, LoadingSpinner, layouts)
├── features/             # Feature modules
│   ├── auth/api + hooks
│   ├── admin/courses/api + hooks
│   ├── instructor/courses/api + hooks
│   ├── instructor/quizzes/api + hooks
│   └── student/catalog|quizzes/api + hooks
├── lib/
│   ├── api/client.ts     # Axios, token refresh, error handling
│   ├── auth/             # AuthContext, ProtectedRoute, RoleGuard
│   └── api/types/        # TypeScript interfaces
├── pages/                # Route-level components (thin)
└── styles/
```

**Rules:**
- API calls only in `features/*/api/` modules
- TanStack Query hooks wrap API modules
- Pages consume hooks, not axios directly
- Optimistic updates only where UX benefits (reorder operations)

---

## 8. File Storage Architecture

Active Storage with environment-specific backends:

| Environment | Backend |
|-------------|---------|
| Development | Local disk (`storage/`) |
| Production | S3-compatible (MinIO, AWS S3, etc.) |

### Resource Types
- Course thumbnails (`Course#thumbnail`)
- Lesson resources: video, PDF, document, image, external link

### Access Control
- Private blobs served through authorized API endpoints only
- Students access resources only when enrolled (or lesson is preview)
- Never expose direct unsigned S3 URLs for private content

---

## 9. Background Jobs

**Default:** Solid Queue (Rails 8, no Redis required in dev)

**Use jobs for:**
- Email notifications
- Certificate PDF generation
- Video transcoding (future)
- Quiz attempt expiry sweeps
- Progress recalculation at scale

**Do not use jobs for:** synchronous request-path CRUD.

---

## 10. Course Progress Calculation

Progress is **computed**, not manually editable.

```
progress_percent = (completed_required_items / total_required_items) × 100
```

### Required items (when implemented fully)
- Published lessons marked `required_for_completion: true` (default: all non-preview)
- Published quizzes with `required_for_completion: true` where `passed: true`
- Graded assignments with `required_for_completion: true` where grade `passed: true`

### Lesson completion
- Status transitions: `not_started → in_progress → completed`
- `MarkLessonComplete` service triggers `RecalculateCourseProgress`

### Quiz completion
- Submitted attempt with `passed: true` (best attempt if retakes allowed)

**Current implementation:** Lessons, required quizzes, and required assignments count toward completion. `Progress::CourseCompletion` computes totals; recalculation runs after lesson updates, quiz submission, and assignment grading. Enrollment responses include `progress_summary`.

---

## 11. Quiz System (Security-Critical)

See [API.md](./API.md) for endpoints. Key security rules:

1. **Never** send `is_correct` on question options to students before submission
2. All scoring in `Quizzes::ScoreAttempt` service on server
3. One `in_progress` attempt per enrollment per quiz at a time
4. `max_attempts` enforced in `Quizzes::StartAttempt`
5. Time limits enforced via `expires_at`; expired attempts cannot be submitted
6. Duplicate submission blocked once status is `submitted`
7. Students can only access their own attempts (`QuizAttemptPolicy`)

---

## 12. Dashboard Designs

### Admin Dashboard
Overview · Users · Instructors · Students · Courses · Categories · Batches · Enrollments · Reports · Announcements · Certificates · Audit Logs · Settings

### Instructor Dashboard
Overview · My Courses · Course Editor · Modules · Lessons · Resources · Quizzes · Assignments · Students · Progress · Grades · Announcements

### Student Dashboard
Overview · My Courses · Catalog · Continue Learning · Progress · Quiz Results · Assignments · Grades · Certificates · Notifications · Profile

**Current UI:** Admin, instructor, and student dashboards are implemented.

---

## 13. Security Design

| Threat | Mitigation |
|--------|------------|
| SQL injection | ActiveRecord parameterized queries |
| XSS | React escaping; HttpOnly cookies; CSP headers (prod) |
| CSRF | SameSite cookies; API-only backend |
| Auth attacks | bcrypt, rate limiting (rack-attack), token rotation |
| Authorization bypass | Pundit on every action; policy specs |
| Mass assignment | Strong params; explicit serializer fields |
| File upload attacks | Content-type validation, size limits, virus scan (prod) |
| IDOR | UUID lookups + policy checks on every record |
| Sensitive data exposure | Role-specific serializers; no correct answers pre-submit |

Run `bin/brakocop`, `bin/rubocop`, Brakeman in CI.

---

## 14. Testing Architecture

| Layer | Tool | Focus |
|-------|------|-------|
| Backend models | RSpec + shoulda | Validations, associations |
| Backend services | RSpec | Business logic, edge cases |
| Backend requests | RSpec | Auth, authorization, happy + forbidden paths |
| Backend policies | RSpec + pundit/rspec | Role matrix (`spec/policies/authorization_matrix_spec.rb`) |
| Backend smoke | RSpec request | End-to-end enroll → learn → complete journey |
| Frontend unit | Vitest | Helpers, components |
| Frontend integration | RTL | Auth redirect, protected routes |
| Load smoke | `scripts/load/smoke.rb` | Concurrent health/catalog requests against running server |

**Coverage targets:** backend ≥ 75% line / 45% branch (SimpleCov, enforced in CI). Frontend coverage report via `npm run test:coverage`; prioritize helpers and auth flows.

**Always test unauthorized paths**, not just happy paths.

---

## 15. Deployment Architecture

```
                    ┌─────────────┐
                    │   Caddy/    │
                    │   Nginx     │
                    └──────┬──────┘
              ┌────────────┼────────────┐
              ▼            ▼            ▼
         Rails API    React static    S3
              │                         ▲
              ▼                         │
         PostgreSQL              Active Storage
              │
         Solid Queue worker(s)
```

Environment variables: `DATABASE_*`, `JWT_SECRET`, `FRONTEND_URL`, `AWS_*` (prod storage).

---

## 16. Implementation Roadmap

Work **one phase at a time**. Inspect existing code before each phase. Run tests before moving on.

| Phase | Name | Key Deliverables |
|-------|------|------------------|
| 0 | Project setup | Docker, docs, linting, CI skeleton |
| 1 | Auth foundation | Rails API, login/register/refresh, RSpec |
| 2 | Users & roles | Role assignment, Pundit, role-scoped routes |
| 3 | Courses & categories | CRUD, publish, search/filter/paginate |
| 4 | Modules & lessons | Nested structure, reorder, Active Storage |
| 5 | Enrollment | Self-enroll, admin enroll, duplicate prevention |
| 6 | Student learning | Lesson viewer, continue learning, resource download |
| 7 | Progress | Deterministic calculation, completion criteria |
| 8 | Quizzes | Full attempt lifecycle, server-side scoring |
| 9 | Assignments | Submit, grade, notifications |
| 10 | Certificates | Auto-issue on completion |
| 11 | Notifications & announcements | In-app + email |
| 12 | Reviews | Course ratings |
| 13 | Admin dashboard & reports | Analytics, audit logs |
| 14 | Instructor dashboard | Full instructor UX |
| 15 | Student dashboard | Full student UX |
| 16 | Security & performance | **Done** — rate limiting, caching, OWASP headers |
| 17 | Testing & hardening | **Done** — SimpleCov, CI test jobs, smoke/load scripts |
| 18 | Docker & deployment | **Done** — production compose, Kamal, Caddy proxy |

---

## 17. Key Architectural Decisions

| Decision | Choice | Tradeoff |
|----------|--------|----------|
| Auth | JWT + HttpOnly refresh cookie | Slightly more complex than session-only; better XSS resistance |
| Authorization | Pundit policies | Verbose but explicit and testable |
| Serialization | Alba | Fast; manual field control per role |
| Pagination | Pagy | Lightweight; meta in response envelope |
| Module naming | `CourseModule` model (table: `course_modules`) | Avoids Ruby `Module` constant conflict |
| Course delete | Archive (soft) for admin | Preserves enrollment history |
| Quiz answers table | `question_options` (not `answers`) | Avoids confusion with quiz responses |
| Background jobs | Solid Queue default | No Redis in dev; add Redis only if needed |
| Frontend state | TanStack Query for server state | No Redux needed for this app size |

---

## 18. Agent Rules (Mandatory)

1. Do **not** implement the entire LMS in one response
2. Work phase-by-phase; inspect repo before each phase
3. Follow this documentation as source of truth
4. Never create fake/placeholder APIs
5. Never use mock data in production paths
6. Every feature needs appropriate tests
7. Run tests after changes; fix failures before proceeding
8. Never bypass authorization
9. Update docs when architectural decisions change
10. Prefer simple solutions over abstractions

---

## 19. Next Step

All planned implementation phases (0–18) are complete.

**Suggested follow-ups (post-roadmap):**
- OpenAPI/Swagger documentation generation
- Email delivery (SMTP) for password reset and notifications
- CDN deployment for the React SPA alongside Kamal-hosted API
- Multi-tenant organizations support
