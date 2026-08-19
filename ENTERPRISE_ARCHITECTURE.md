# DailyCatch Enterprise Architecture

## Principe

L'app Flutter ne doit pas porter la logique critique: paiements, validation des commandes, remboursements, validation partenaire, droits admin et webhooks. Ces operations doivent passer par le backend.

## Stack cible

- Mobile: Flutter.
- Backend: Node.js TypeScript dans `../backend/`.
- Paiement: Stripe PaymentIntents cote serveur.
- Auth: Firebase Auth, avec verification Firebase Admin cote backend pour les routes sensibles.
- Notifications: Firebase Cloud Messaging.
- Stockage images: Firebase Storage ou S3 compatible.
- Donnees metier: PostgreSQL pour commandes, partenaires, offres, paiements et audit trail.
- Observabilite: logs structures, Sentry mobile/backend, alerting.

## Regles de securite

- Aucun secret Stripe dans l'app mobile.
- Creation de PaymentIntent uniquement cote backend.
- Confirmation des paiements via webhook Stripe, pas via confiance dans le client mobile.
- Idempotency key obligatoire pour les operations paiement.
- HTTPS obligatoire en production.
- Cleartext HTTP interdit sur Android.
- Roles client, partenaire et admin verifies cote backend.
- Retrait commande confirme uniquement par `partner`, `support` ou `admin`.
- Remboursement declenche uniquement par `support` ou `admin`.
- Configuration Firebase fournie par environnement, pas par fallback code.
- Token Firebase ID verifie cote backend pour les appels sensibles.
- Evenements Stripe persistés dans PostgreSQL via `../backend/db/schema.sql`.
- `API_KEY` backend interdite en production; elle sert uniquement aux tests/developpement local.
- Montants paiement recalcules cote backend avant encaissement production.

## Prochaine integration mobile

1. Ajouter un service API Flutter pour appeler le backend. Fait.
2. Ajouter `flutter_stripe`. Fait.
3. Remplacer le paiement simule par:
   - creation commande backend en statut `pending_payment`,
   - appel backend `POST /api/v1/payments/payment-intents`,
   - affichage PaymentSheet Stripe,
   - attente confirmation webhook/backend,
   - affichage QR seulement apres paiement confirme.

## Roles backend

- `client`: consulte les offres, cree une commande, paie, annule si autorise, ouvre un ticket support et note apres retrait.
- `partner`: gere ses offres et valide le retrait via QR/code.
- `support`: traite les tickets, peut confirmer un retrait ou declencher un remboursement selon procedure.
- `admin`: supervise les partenaires, remboursements, fraudes, notifications et indicateurs.

Ces roles doivent venir du backend, via custom claims Firebase ou table serveur. L'UI ne doit jamais etre la source d'autorite.

Le parcours vendeur est volontairement en deux temps: l'inscription cree une demande `pending_review`, puis l'admin approuve depuis le back-office. L'approbation appelle le backend, qui attribue le custom claim Firebase `role: partner`.

Les regles Firestore du depot interdisent aux clients de modifier les champs `role`, `requestedRole` et `partnerApplicationStatus`. L'approbation reste une operation backend/admin.

## Lancement local avec Stripe

Backend:

```bash
cd ../backend
cp .env.example .env
npm install
npm run build
npm run db:migrate
npm start
```

Mobile web/local:

```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080 \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_AUTH_DOMAIN=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_STORAGE_BUCKET=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_APP_ID=... \
  --dart-define=FIREBASE_WEB_VAPID_KEY=... \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_replace_me
```

Mobile Android emulator:

```bash
flutter run -d <device-id> \
  --dart-define=API_BASE_URL=http://10.0.2.2:8080 \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_AUTH_DOMAIN=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_STORAGE_BUCKET=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_APP_ID=... \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_replace_me
```

Webhook Stripe local:

```bash
stripe listen --forward-to localhost:8080/api/v1/payments/webhook
```

## Definition de pret production

- `flutter analyze`, `flutter test`, build Android et build web OK.
- Tests backend OK.
- CI obligatoire sur chaque pull request.
- Webhooks Stripe testes en sandbox.
- Regles Firestore/Storage auditees si Firebase est conserve.
- Donnees sensibles jamais stockees en clair.
- Parcours client, partenaire et admin testes bout en bout.
- Commandes creees cote backend avec montant recalcule serveur avant Stripe. Fait pour le backend; l'app mobile doit maintenant appeler `POST /api/v1/orders` avant Stripe.
