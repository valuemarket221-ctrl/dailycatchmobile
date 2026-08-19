# DailyCatch Deployment Runbook

## Local PostgreSQL

Prerequis: Docker daemon running.

```bash
cd ../backend
npm install
npm run db:setup
npm run test:integration
```

Useful commands:

```bash
npm run db:logs
npm run db:down
npm run db:reset
```

Default local database:

```text
postgres://dailycatch:dailycatch@127.0.0.1:5433/dailycatch
```

## Backend Local

```bash
cd ../backend
cp .env.example .env
npm run build
npm start
curl http://127.0.0.1:8080/health
```

## Production Backend Environment

Required:

```text
NODE_ENV=production
PORT=8080
APP_ORIGIN=https://your-web-origin.example
DATABASE_URL=postgres://...
FIREBASE_PROJECT_ID=...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

Do not set `API_KEY` in production. The backend rejects startup with `NODE_ENV=production` if `API_KEY` is present.

`APP_ORIGIN` must be an HTTPS public origin in production. Localhost origins are rejected at startup.

`DATABASE_URL` must use `postgres://` or `postgresql://` and point to a non-local production database. The backend enables PostgreSQL TLS in production.

## Database Deployment

Run once per environment before starting the backend:

```bash
cd ../backend
DATABASE_URL=postgres://... npm run db:migrate
```

Seed only development/sandbox data:

```bash
DATABASE_URL=postgres://... npm run db:seed
```

## Backend Docker Image

Local build:

```bash
cd ../backend
docker build -t dailycatch-backend .
docker run --rm -p 8080:8080 --env-file .env dailycatch-backend
```

Run scheduled backend jobs from the same image:

```bash
docker run --rm --env-file .env dailycatch-backend npm run notifications:worker
docker run --rm --env-file .env dailycatch-backend npm run orders:expire
```

Recommended scheduler:

```text
notifications:worker  every 1 minute
orders:expire         every 1 to 5 minutes
```

GitHub CD publishes the backend image to:

```text
ghcr.io/<owner>/<repo>/dailycatch-backend
```

Trigger CD:

```bash
git tag v0.1.0
git push origin v0.1.0
```

or run the `CD` workflow manually.

## Flutter Builds

CI validates:

```bash
flutter analyze
flutter test
flutter build web --debug --no-wasm-dry-run
flutter build apk --debug
```

CD builds and uploads a release web artifact from `build/web`.

Production mobile builds must provide:

```bash
--dart-define=API_BASE_URL=https://your-backend.example
--dart-define=FIREBASE_API_KEY=...
--dart-define=FIREBASE_AUTH_DOMAIN=...
--dart-define=FIREBASE_PROJECT_ID=...
--dart-define=FIREBASE_STORAGE_BUCKET=...
--dart-define=FIREBASE_MESSAGING_SENDER_ID=...
--dart-define=FIREBASE_APP_ID=...
--dart-define=FIREBASE_WEB_VAPID_KEY=...
--dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_...
--dart-define=MAP_TILE_URL_TEMPLATE=https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=...
--dart-define=MAP_TILE_USER_AGENT_PACKAGE_NAME=com.dailycatch.app
```

For local Android/Chrome runs against the local backend, use `MOBILE_LOCAL_RUNBOOK.md`.

## Stripe

1. Configure the backend with `STRIPE_SECRET_KEY`.
2. Configure a Stripe webhook pointing to:

```text
https://your-backend.example/api/v1/payments/webhook
```

3. Store the signing secret in `STRIPE_WEBHOOK_SECRET`.
4. Verify sandbox flow before live keys:
   offer -> cart -> order -> PaymentIntent -> PaymentSheet -> webhook -> order `paid`.

Local Stripe CLI:

```bash
cd ../backend
stripe login
npm run stripe:listen
```

Copy the printed `whsec_...` to `STRIPE_WEBHOOK_SECRET`, restart the backend, then trigger a sandbox event:

```bash
npm run stripe:trigger
```

## Release Gate

Do not release if any item fails:

- GitHub CI green.
- Backend `npm audit --audit-level=high` clean.
- Review any moderate npm audit findings and avoid force-fixes that downgrade critical SDKs without regression testing.
- Database migrations applied.
- Stripe webhook receives signed sandbox event.
- Firebase project values supplied by environment.
- Android/iOS app tested against the deployed backend.
