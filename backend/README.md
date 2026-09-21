# LMS Backend

Rails 8 JSON API for the Learning Management System.

## Requirements

- Ruby 3.4+
- PostgreSQL 16+
- Bundler

## Local setup (without Docker)

```bash
cd backend
cp ../.env.example ../.env
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

API base URL: `http://localhost:3000/api/v1`

## Docker setup

From the repository root:

```bash
docker compose up --build
```

This starts PostgreSQL and the Rails API on port 3000.

## Running tests

```bash
cd backend
bin/rails db:test:prepare
bundle exec rspec
```

## Linting

```bash
cd backend
bin/rubocop
```

## Auth endpoints

| Method | Path |
|--------|------|
| POST | `/api/v1/auth/register` |
| POST | `/api/v1/auth/login` |
| POST | `/api/v1/auth/refresh` |
| DELETE | `/api/v1/auth/logout` |
| GET | `/api/v1/auth/me` |
| POST | `/api/v1/auth/forgot_password` |
| POST | `/api/v1/auth/reset_password` |

Login example:

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth":{"email":"admin@example.com","password":"password123"}}'
```

After seeding, a development admin user is available at `admin@example.com` / `password123`.
