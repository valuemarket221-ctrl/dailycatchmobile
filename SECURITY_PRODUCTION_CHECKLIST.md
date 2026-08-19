# DailyCatch Security Production Checklist

## Obligatoire avant mise en production

- Activer HTTPS partout, avec HSTS au niveau du reverse proxy/CDN.
- Deployer le backend avec `NODE_ENV=production`.
- Fournir les secrets via le gestionnaire de secrets de l'hebergeur, jamais dans Git.
- Configurer `DATABASE_URL`, `FIREBASE_PROJECT_ID`, `STRIPE_SECRET_KEY` et `STRIPE_WEBHOOK_SECRET`.
- Utiliser une `DATABASE_URL` PostgreSQL non locale en production; le backend force TLS.
- Configurer `APP_ORIGIN` sur une origine publique HTTPS, jamais localhost en production.
- Ne pas definir `API_KEY` en production; le backend refuse le demarrage si elle est presente.
- Executer `../backend/db/schema.sql` sur PostgreSQL.
- Deployer `firestore.rules` et `storage.rules` avant toute ouverture publique.
- Verifier les tokens Firebase ID cote backend pour toutes les routes sensibles.
- Ajouter une strategie de revocation de session si le niveau de risque l'exige.
- Verifier les roles serveur pour les actions admin et partenaire.
- Configurer les roles serveur avec custom claims Firebase ou table serveur:
  `client`, `partner`, `support`, `admin`.
- Creer le premier admin avec le script backend `npm run roles:set -- --email ... --role admin`.
- Verifier que la validation de retrait est limitee aux roles `partner`, `support` et `admin`.
- Verifier que les remboursements sont limites aux roles `support` et `admin`.
- Confirmer les paiements uniquement depuis les webhooks Stripe signes.
- Recalculer les montants cote backend depuis `product_offers`.
- Configurer et surveiller le rate limiting backend pour commandes, paiements, support, vendeur et admin.
- Utiliser une cle d'idempotence sur la creation de commande pour eviter doubles reservations et retries dangereux.
- Rendre la creation PaymentIntent recuperable: meme commande, meme PaymentIntent/clientSecret.
- Restaurer le stock reserve quand Stripe annule definitivement un PaymentIntent.
- Planifier le worker `orders:expire` pour liberer les commandes `pending_payment` abandonnees.
- Journaliser les actions sensibles: paiement, remboursement, validation partenaire, changement de role.
- Activer monitoring, alerting, erreurs applicatives et logs centralises.
- Lancer `flutter analyze`, `flutter test`, build Android, build web, `npm run build` et `npm test` en CI.
- Bloquer la CI sur les vulnerabilites backend `npm audit --audit-level=high`.
- Construire et verifier l'image Docker backend avant de deployer.
- Executer les tests d'integration PostgreSQL en CI avec `DATABASE_URL`.

## Deja couvert dans ce depot

- Pas de secret Stripe dans l'app Flutter.
- Cleartext HTTP Android bloque par configuration reseau.
- Cleartext HTTP Android autorise seulement en debug/profile pour localhost et emulator.
- Configuration Firebase mobile fournie par `--dart-define`, sans fallback hardcode.
- Backend Express avec Helmet, CORS restreint, validation Zod, logs structures.
- Configuration production refuse `APP_ORIGIN` local ou non HTTPS.
- Configuration production refuse `DATABASE_URL` locale ou non PostgreSQL.
- Auth backend par Firebase ID token en production.
- Configuration production refuse `API_KEY` pour eviter tout bypass dev.
- Approbation vendeur via backend admin avec attribution du custom claim `role: partner`.
- Regles Firestore presentes: le client ne peut pas modifier son role ni approuver sa demande vendeur.
- Regles Storage presentes: upload limite aux images et refuse par defaut hors chemins autorises.
- Validation retrait protegee cote backend par role `partner`, `support` ou `admin`.
- Rate limiting Express present sur les routes publiques, sensibles, paiement, vendeur et admin.
- Creation de commande idempotente par utilisateur via `idempotencyKey`.
- Creation PaymentIntent idempotente cote Stripe et recuperation du PaymentIntent existant.
- Webhook `payment_intent.canceled` restaure le stock reserve transactionnellement.
- Worker `orders:expire` present pour expirer les reservations non payees et restaurer le stock.
- Audit SQL present pour les actions admin sensibles: tickets support et validation vendeur.
- Webhook Stripe verifie par signature.
- Audit PostgreSQL des PaymentIntents et evenements Stripe.
- CI GitHub Actions pour Flutter et backend.
- CI backend avec `npm audit --audit-level=high`.
- CD GitHub Actions pour image Docker backend et artefact Flutter web.
- PostgreSQL local reproductible via `../backend/compose.yaml`.

## Risques restants a traiter avant encaissement reel

- L'app mobile doit etre raccordee au nouvel endpoint `POST /api/v1/orders`; le backend est pret a calculer le montant depuis `product_offers`.
- Les IDs produits affiches par l'app doivent venir du backend et correspondre a `product_offers.id`; les IDs generes localement ne sont pas acceptables en production.
- Les regles Firebase doivent etre testees avec l'emulateur avant le lancement public.
- Auditer regulierement les custom claims Firebase et les comptes admin/support actifs.
- Un test bout en bout sandbox Stripe doit couvrir PaymentSheet, webhook et confirmation commande.
