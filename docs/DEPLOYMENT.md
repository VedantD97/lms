# LMS Deployment Guide

Production deployment options for the Learning Management System monorepo.

---

## Option A: Docker Compose (full stack)

Best for a single VPS or local production-like testing. Runs PostgreSQL, Rails API, React SPA, and a Caddy reverse proxy.

> **Local fallback:** If Docker Compose is unavailable, use native deployment instead:
> ```bash
> bin/prod-native
> ```
> Stop with `bin/prod-down-native`.

### 1. Configure secrets

```bash
cp .env.production.example .env.production
```

Edit `.env.production`:

| Variable | Description |
|----------|-------------|
| `POSTGRES_PASSWORD` | Database password |
| `RAILS_MASTER_KEY` | Contents of `backend/config/master.key` |
| `JWT_SECRET` | Long random string for JWT signing |
| `APP_HOST` | Public hostname (use `localhost` for local compose) |
| `FRONTEND_URL` | Public app URL (e.g. `http://localhost:8080`) |
| `FORCE_SSL` | Set `false` for local HTTP; `true` behind HTTPS proxy |

### 2. Start the stack

```bash
bin/prod-up
```

Open http://localhost:8080 (or your `PROXY_PORT`).

### 3. Seed demo data (first run)

```bash
docker compose -f docker-compose.prod.yml --env-file .env.production \
  exec backend bin/rails db:seed
```

Or load demo records explicitly:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.production \
  exec -e SEED_DUMMY_DATA=1 backend bin/rails db:seed
```

Default admin: `admin@example.com` / `password123`

See [DEVELOPMENT.md](./DEVELOPMENT.md#seed-credentials) for all demo accounts and scenarios.

### 4. Stop the stack

```bash
bin/prod-down
```

### Architecture

```
Caddy (:8080)
  /api/*  → Rails API (Thruster :80)
  /*      → Nginx static SPA
              ↓
         PostgreSQL (primary + cache + queue DBs)
```

Uploaded files persist in the `backend_storage` Docker volume. Set `ACTIVE_STORAGE_SERVICE=amazon` and AWS variables for S3.

---

## Option B: Kamal (Rails API on VPS)

Best for cloud/VPS deployment of the API with automatic SSL via kamal-proxy.

### 1. Prerequisites

- VPS with Docker (Ubuntu 22.04+ recommended)
- Domain DNS pointing to the server
- Container registry (GitHub Container Registry or Docker Hub)

### 2. Configure deployment

Edit `backend/config/deploy.yml`:

- `image` — your registry image name
- `servers.web.hosts` — server IP
- `proxy.host` — your domain
- `registry` — registry credentials

### 3. Configure secrets

```bash
cd backend
cp .kamal/secrets.example .kamal/secrets
# Export or paste real values, then deploy
export KAMAL_REGISTRY_PASSWORD=...
export RAILS_MASTER_KEY=...
export JWT_SECRET=...
export POSTGRES_PASSWORD=...
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_BUCKET=...
```

### 4. Deploy

```bash
cd backend
bundle exec kamal setup    # first time
bundle exec kamal deploy   # subsequent releases
```

Useful aliases (defined in `deploy.yml`):

```bash
bundle exec kamal app logs -f
bundle exec kamal console
bundle exec kamal shell
```

### Frontend with Kamal

The Kamal config deploys the **Rails API only**. Serve the React SPA using one of:

1. **Same domain via CDN/object storage** — build with `cd frontend && npm run build`, upload `dist/` to S3 + CloudFront (or similar) with `VITE_API_URL=https://your-domain.com/api/v1`
2. **Docker Compose production stack** — Option A above for all-in-one hosting
3. **Separate static host** — Netlify, Cloudflare Pages, etc. pointing API calls to your Kamal host

---

## Option C: Render (free tier)

Best for a free, zero-VPS deployment for demos/portfolios. Uses the [render.yaml](../render.yaml) Blueprint at the repo root, which defines three resources: a free Postgres instance, the Rails API (built from `backend/Dockerfile`), and the React SPA (built as a static site).

> **Free-tier caveats:** the free web service sleeps after 15 minutes idle (first request after that takes ~30s to wake up), and Render's free Postgres [expires 30 days after creation](https://render.com/changelog/free-postgresql-instances-now-expire-after-30-days-previously-90) with a 14-day grace period before deletion — fine for a demo, not for anything long-lived. For a free database with no expiration, point `DATABASE_HOST`/`DATABASE_USERNAME`/`DATABASE_PASSWORD` at [Neon](https://neon.tech) instead.

### 1. Create the Blueprint

In the Render dashboard: **New +** → **Blueprint** → connect this GitHub repo → Render parses `render.yaml` and proposes `lms-postgres`, `lms-backend`, and `lms-frontend`. Apply it.

Several env vars are deliberately left blank in the blueprint (`sync: false`) because their values don't exist until a resource has been created once. Fill them in after the first apply, in this order:

### 2. Wire up the database

Open `lms-postgres` → **Info** tab, then set on `lms-backend`:

| Env var | Value |
|---------|-------|
| `DATABASE_HOST` | "Hostname" field |
| `DATABASE_USERNAME` | "Username" field |
| `DATABASE_PASSWORD` | "Password" field |

### 3. Set the backend's own secrets

On `lms-backend`, set:

| Env var | Value |
|---------|-------|
| `RAILS_MASTER_KEY` | contents of `backend/config/master.key` |

`JWT_SECRET` is already auto-generated by the blueprint (`generateValue: true`).

Saving these triggers an automatic redeploy of `lms-backend`. On boot, `bin/docker-entrypoint` runs `rails db:prepare`, which also creates the `lms_production_cache`, `lms_production_queue`, and `lms_production_cable` databases on the same Postgres instance (mirroring what `deploy/postgres/init-multiple-dbs.sh` does for Option A) — check the deploy logs; if it fails with a permissions error, create those three databases manually via `psql` using the External Connection string from `lms-postgres`.

### 4. Point the frontend at the backend

Once `lms-backend` is live, copy its URL (top of its Render page, e.g. `https://lms-backend.onrender.com`) and set on `lms-frontend`:

| Env var | Value |
|---------|-------|
| `VITE_API_URL` | `https://lms-backend.onrender.com/api/v1` |

Static site env vars are baked in at build time, so trigger **Manual Deploy → Deploy latest commit** on `lms-frontend` after setting it.

### 5. Point the backend back at the frontend

Copy `lms-frontend`'s URL and set on `lms-backend`:

| Env var | Value |
|---------|-------|
| `FRONTEND_URL` | `https://lms-frontend.onrender.com` |

This is used for CORS (`backend/config/initializers/cors.rb`) and redeploys `lms-backend` automatically.

### 6. Verify APP_HOST

`render.yaml` sets `APP_HOST` to `lms-backend.onrender.com`. If Render appended a random suffix to the service name (shown in its URL), update `APP_HOST` to match — otherwise requests will fail Rails' host authorization check.

### 7. Seed demo data

From the Render dashboard, open a shell on `lms-backend` (**Shell** tab) and run:

```bash
bin/rails db:seed
```

Default admin: `admin@example.com` / `password123` — see [DEVELOPMENT.md](./DEVELOPMENT.md#seed-credentials) for all demo accounts.

---

## Environment reference

See [.env.production.example](../.env.production.example) and [DEVELOPMENT.md](./DEVELOPMENT.md#10-environment-variables).

### Production-only variables

| Variable | Default | Description |
|----------|---------|-------------|
| `RAILS_MASTER_KEY` | — | Decrypts Rails credentials |
| `FORCE_SSL` | `true` | HTTPS redirect + secure cookies |
| `SOLID_QUEUE_IN_PUMA` | — | Run background jobs inside Puma (single-server) |
| `ACTIVE_STORAGE_SERVICE` | `local` | `local` or `amazon` |
| `APP_HOST` | — | Host authorization + mailer links |

---

## Health checks

| Endpoint | Use |
|----------|-----|
| `GET /api/v1/health` | Application health (JSON) |
| `GET /up` | Rails load-balancer probe |

Kamal proxy health check uses `/api/v1/health`.

---

## Troubleshooting

**Database not ready:** Wait for Postgres health check, then restart backend:
```bash
docker compose -f docker-compose.prod.yml restart backend
```

**502 from Caddy:** Check backend logs:
```bash
docker compose -f docker-compose.prod.yml logs backend
```

**Host authorization error:** Set `APP_HOST` to the public hostname clients use.

**SSL redirect loop (compose):** Set `FORCE_SSL=false` when testing over plain HTTP locally.
