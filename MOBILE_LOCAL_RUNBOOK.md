# DailyCatch Mobile Local Runbook

## Backend local

```bash
cd ../backend
npm run db:setup
setsid env DATABASE_URL=postgres://dailycatch:dailycatch@127.0.0.1:5433/dailycatch npm start > /tmp/dailycatch_backend.log 2>&1 &
curl http://127.0.0.1:8080/health
```

## Variables mobile

```bash
cp .env.mobile.example .env.mobile
set -a
. ./.env.mobile
set +a
```

## Android Emulator

Android Emulator accede au backend hote via `10.0.2.2`.

```bash
./scripts/flutter_run_local_android.sh -d <device-id>
```

Le cleartext HTTP est autorise uniquement en debug/profile pour:

- `10.0.2.2`
- `127.0.0.1`
- `localhost`

La configuration release reste stricte via `android/app/src/main/res/xml/network_security_config.xml`.

## Chrome

```bash
./scripts/flutter_run_local_chrome.sh
```

## Stripe sandbox

```bash
cd ../backend
stripe login
npm run stripe:listen
```

Copier le `whsec_...` affiche par Stripe CLI dans `../backend/.env`, relancer le backend, puis tester le parcours paiement.
