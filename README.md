# Learning Management System

Production-ready LMS built with **Rails 8 API**, **React + TypeScript**, and **PostgreSQL**.

## Quick start (development)

```bash
docker compose up
```

| Service | URL |
|---------|-----|
| Frontend | http://localhost:5173 |
| API | http://localhost:3000/api/v1 |
| Admin login | `admin@example.com` / `password123` |

See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for native setup and workflow.

## Documentation

| Document | Purpose |
|----------|---------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | System design and roadmap |
| [API.md](docs/API.md) | REST endpoints |
| [DATABASE.md](docs/DATABASE.md) | Schema reference |
| [DEVELOPMENT.md](docs/DEVELOPMENT.md) | Local dev and testing |
| [DEPLOYMENT.md](docs/DEPLOYMENT.md) | Production deployment |

## Testing

```bash
bin/ci
```

- Backend: 185+ RSpec examples with SimpleCov (≥ 75% line coverage)
- Frontend: Vitest + production build

## Production deployment

**Docker Compose (full stack):**

```bash
cp .env.production.example .env.production
# edit secrets
bin/prod-up
```

**Kamal (API on VPS):**

```bash
cd backend
cp .kamal/secrets.example .kamal/secrets
bundle exec kamal setup
```

Details: [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

**Native (no Docker):**

```bash
cp .env.production.example .env.production
bin/prod-native
```

## Project structure

```
backend/     Rails 8 JSON API
frontend/    React + Vite SPA
docs/        Architecture documentation
deploy/      Caddy proxy and Postgres init scripts
bin/ci         Full test pipeline
bin/prod-up    Start production Docker stack
```
