# LMS Development Guide

**Version:** 1.0

See [ARCHITECTURE.md](./ARCHITECTURE.md) for system design and [API.md](./API.md) for endpoint reference.

---

## 1. Prerequisites

| Tool | Version |
|------|---------|
| Ruby | 3.4+ |
| Rails | 8.x |
| Node.js | 20+ |
| PostgreSQL | 16+ |
| Docker & Docker Compose | Latest stable |

---

## 2. Repository Structure

```
/
├── backend/           # Rails 8 API-only app
├── frontend/          # React + Vite + TypeScript SPA
├── docs/              # Architecture documentation (source of truth)
├── docker-compose.yml # Dev environment
└── README.md
```

---

## 3. Local Setup

### Option A: Docker Compose (recommended)

```bash
docker compose up
```

| Service | URL |
|---------|-----|
| Backend API | http://localhost:3000 |
| Frontend | http://localhost:5173 |
| PostgreSQL | localhost:5432 |

### Option B: Native

**Backend:**

```bash
cd backend
bundle install
bin/rails db:prepare db:seed
bin/rails server
```

**Frontend:**

```bash
cd frontend
npm install
npm run dev
```

**Environment:**

```bash
# frontend/.env
VITE_API_URL=/api/v1
```

Frontend dev server proxies `/api` → `http://localhost:3000`.

### Seed Credentials

All demo accounts use password **`password123`**.

| Email | Role | Scenario |
|-------|------|----------|
| `admin@example.com` | Admin | Dashboard, reports, moderation |
| `superadmin@example.com` | Super Admin | Audit logs |
| `instructor@example.com` | Instructor | Rails + React courses, grading queue |
| `instructor2@example.com` | Instructor | PostgreSQL course |
| `student@example.com` | Student | In progress (Rails), partial lessons + quiz started |
| `student2@example.com` | Student | Completed React course + certificate |
| `student3@example.com` | Student | New enrollment (PostgreSQL) |
| `student4@example.com` | Student | Assignment awaiting grading (Rails) |

Demo data loads automatically in **development**. For production/staging:

```bash
SEED_DUMMY_DATA=1 bin/rails db:seed
```

Re-running seeds is idempotent — demo data is skipped if already present.

Additional users created by seeds — check `backend/db/seeds/demo_data.rb`.

---

## 4. Development Workflow

### 4.1 Phase-by-Phase Development

1. Read the relevant section in [ARCHITECTURE.md](./ARCHITECTURE.md)
2. Inspect existing code — do not overwrite working implementations
3. Implement the phase scope only
4. Write tests (model, service, request, policy as appropriate)
5. Run test suite and linters
6. Fix all failures before proceeding
7. Update docs if architectural decisions change

### 4.2 Branch Naming

```
feature/phase-8-quiz-expiry
fix/enrollment-duplicate-race
docs/api-endpoints
```

### 4.3 Commit Messages

Complete sentences describing **why**, not just what:

```
Add quiz attempt expiry to prevent late submissions.

Enforce time limits server-side via expires_at and reject
submit when attempt is expired.
```

---

## 5. Backend Standards

### 5.1 Controllers

- Thin controllers: authorize → delegate → render
- Use `policy_scope` for index actions
- Use `render_service_failure(result)` for service errors
- Never skip authorization

```ruby
def create
  record = Model.new(permitted_params)
  authorize record
  if record.save
    render_data(serialize(record), status: :created)
  else
    render_record_invalid(ActiveRecord::RecordInvalid.new(record))
  end
end
```

### 5.2 Services

Create services for multi-step workflows:

```
app/services/
├── auth/
├── courses/
├── enrollments/
├── progress/
└── quizzes/
```

Return `ServiceResult::Base.success(data)` or `.failure(errors:, error_code:)`.

### 5.3 Policies

Every model with API exposure needs a policy. Test forbidden paths.

### 5.4 Serializers

- Namespace: `Api::V1::*Serializer`
- Expose UUIDs, not integer IDs
- Role-specific serializers when field visibility differs (e.g. `StudentQuestionSerializer`)

### 5.5 Migrations

See [DATABASE.md](./DATABASE.md). Run migrations and tests after each one.

### 5.6 N+1 Prevention

Use `includes` / `preload` in controllers and services. Bullet gem recommended for dev.

---

## 6. Frontend Standards

### 6.1 Feature Module Pattern

```
features/{role}/{domain}/
├── api/{domain}Api.ts      # HTTP calls only
└── hooks/use{Domain}.ts    # TanStack Query wrappers
```

Pages in `pages/{role}/` consume hooks — never import axios in pages.

### 6.2 TypeScript

- Strict mode enabled
- Types in `lib/api/types/`
- No `any` without justification

### 6.3 State Management

| State type | Tool |
|------------|------|
| Server state | TanStack Query |
| Form state | React Hook Form + Zod |
| Auth session | AuthContext + Query |

### 6.4 UI Requirements

Every important page must handle:
- **Loading** — spinner or skeleton
- **Error** — user-friendly message via `getErrorMessage()`
- **Empty** — `EmptyState` component
- **Success** — feedback on mutations where appropriate

### 6.5 Routing

- `ProtectedRoute` — requires authentication
- `RoleGuard` — requires specific role(s)
- Role-based redirect from `/` via `HomeRedirect`

---

## 7. Testing

### 7.1 Backend

```bash
cd backend
bundle exec rspec                    # All tests
COVERAGE=true bundle exec rspec      # With SimpleCov report (coverage/index.html)
bundle exec rspec spec/requests/     # Request specs only
bin/rubocop                          # Lint
bin/brakeman                         # Security scan
```

**Coverage gate:** SimpleCov enforces ≥ 75% line and ≥ 45% branch coverage when `COVERAGE` is not `false`. CI runs with coverage enabled.

**Required for new features:**
- Model specs (validations, associations)
- Request specs (happy path + 403 forbidden)
- Service specs (business logic edge cases)
- Policy specs (role matrix) — add cases to `spec/policies/authorization_matrix_spec.rb`

### 7.2 Frontend

```bash
cd frontend
npm test                             # Vitest
npm run test:coverage                # Vitest + HTML coverage report
npm run build                        # Type check + build
npm run lint                         # oxlint
```

**Required for new features:**
- Unit tests for helpers and non-trivial components
- Integration tests for critical flows (auth, quiz submit, enroll)

### 7.3 Full local CI

From the repository root:

```bash
bin/ci
```

Runs RuboCop, Brakeman, RSpec (with coverage), frontend lint, tests, coverage report, and production build.

### 7.4 Load smoke test

With the API running locally (`bin/rails server` or Docker):

```bash
ruby scripts/load/smoke.rb
```

Environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `LOAD_TEST_URL` | `http://localhost:3000` | API base URL |
| `LOAD_TEST_CONCURRENCY` | `10` | Parallel workers |
| `LOAD_TEST_REQUESTS` | `20` | Requests per worker |
| `LOAD_TEST_PATHS` | `/api/v1/health,/api/v1/categories` | Comma-separated paths |
| `LOAD_TEST_MIN_SUCCESS_RATE` | `95` | Fail if below this % |
| `LOAD_TEST_MAX_P95_MS` | `500` | Fail if p95 latency exceeds this |

### 7.5 What to Always Test

- Authorization (403 for wrong role)
- Duplicate enrollment prevention
- Quiz scoring (server-side)
- Quiz attempt limits
- Progress recalculation
- IDOR — accessing another user's resources returns 403/404

---

## 8. Code Quality Tools

| Tool | Scope | Command |
|------|-------|---------|
| RuboCop | Backend style | `bin/rubocop` |
| Brakeman | Backend security | `bin/brakeman` |
| RSpec | Backend tests | `bundle exec rspec` |
| SimpleCov | Backend coverage | `COVERAGE=true bundle exec rspec` |
| oxlint | Frontend lint | `npm run lint` |
| Vitest | Frontend tests | `npm test` |
| Vitest coverage | Frontend coverage report | `npm run test:coverage` |
| TypeScript | Frontend types | `npm run build` |

---

## 9. Docker Services

```yaml
# docker-compose.yml
services:
  db:        PostgreSQL 16
  backend:   Rails on port 3000
  frontend:  Vite on port 5173
```

Volumes:
- `postgres_data` — database persistence
- `bundle_cache` — Ruby gems cache
- `frontend_node_modules` — Node modules cache

---

## 10. Environment Variables

### Backend

| Variable | Description |
|----------|-------------|
| `DATABASE_HOST` | PostgreSQL host ( `db` in Docker) |
| `DATABASE_USERNAME` | DB user |
| `DATABASE_PASSWORD` | DB password |
| `JWT_SECRET` | Token signing secret |
| `FRONTEND_URL` | CORS / cookie origin |
| `RAILS_ENV` | development / production |
| `APP_HOST` | Allowed host in production (host authorization) |
| `RATE_LIMIT_LOGIN` | Login attempts per 20 min (default `5`) |
| `RATE_LIMIT_REGISTER` | Registrations per hour (default `3`) |
| `RATE_LIMIT_PASSWORD` | Forgot/reset password per hour (default `5`) |
| `RATE_LIMIT_API` | Authenticated API requests per 5 min (default `300`) |

### Frontend

| Variable | Description |
|----------|-------------|
| `VITE_API_URL` | API base URL (default `/api/v1`) |

### Production (additional)

| Variable | Description |
|----------|-------------|
| `AWS_ACCESS_KEY_ID` | S3 storage |
| `AWS_SECRET_ACCESS_KEY` | S3 storage |
| `AWS_BUCKET` | S3 bucket name |
| `REDIS_URL` | Optional, for cache/queue at scale |
| `APP_HOST` | Public hostname for Rails host authorization |
| `RATE_LIMIT_*` | Override rack-attack limits (see backend table above) |
| `RAILS_MASTER_KEY` | Rails credentials decryption |
| `FORCE_SSL` | HTTPS redirect (`true` in production, `false` for local compose) |
| `SOLID_QUEUE_IN_PUMA` | Run Solid Queue inside Puma (single-server) |
| `ACTIVE_STORAGE_SERVICE` | `local` or `amazon` |

See [DEPLOYMENT.md](./DEPLOYMENT.md) for production Docker Compose and Kamal setup.

---

## 11. Common Tasks

### Reset database

```bash
cd backend
bin/rails db:drop db:create db:migrate db:seed
```

### Run single spec

```bash
bundle exec rspec spec/requests/api/v1/quizzes_spec.rb:43
```

### Generate migration

```bash
bin/rails generate migration AddRequiredToLessons required_for_completion:boolean
```

---

## 12. Do Not

- Implement entire LMS in one PR
- Put API calls directly in React page components
- Skip authorization checks
- Expose `is_correct` to students before quiz submission
- Store manually editable progress percentages without service recalculation
- Commit secrets (.env with real credentials)
- Skip tests for "simple" features
- Use mock/fake APIs in production code paths
- Leave TODO implementations in code claimed as complete

---

## 13. Documentation Updates

When you change architecture, update the relevant doc:

| Change | Update |
|--------|--------|
| New table | DATABASE.md |
| New endpoint | API.md |
| New env var | DEVELOPMENT.md |
| Design decision | ARCHITECTURE.md |
| Phase completed | ARCHITECTURE.md §16 status table |
