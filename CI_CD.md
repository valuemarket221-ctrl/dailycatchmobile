# Mobile CI/CD

## Integration continue

`.github/workflows/ci.yml` tourne sur les push de toutes les branches, les pull requests et sur demande.
Environnement fixe : Ubuntu 24.04, Flutter 3.44.8, Java Temurin 17.
Le lockfile est impose. Analyse, tests avec couverture, compilation web debug et compilation Android debug sont bloquants.
Les rapports de couverture et le build web de validation sont conserves comme artefacts GitHub Actions.
Le build Android debug est un controle de compilation sans compte Firebase ni signature de distribution ; il ne prouve pas que les services externes fonctionnent.

## Livraison continue

`.github/workflows/cd.yml` propose deux cibles au lancement manuel :

- `validation` : analyse, tests, build web debug et artefact identifie validation. Pas un livrable de production ; aucune configuration de service reel n'est injectee.
- `production` : configuration obligatoire, controle de cette configuration, analyse, tests, build release, artefact identifie production.

Un tag `v*` selectionne la cible production. Les artefacts portent le SHA du commit et contiennent REVISION.txt.
Le workflow ne deploie pas sur un serveur, Firebase Hosting ou un store. Aucun hebergement n'a encore ete choisi/configure.

## Configuration production

Dans GitHub, creer la variable `MOBILE_RELEASE_CONFIG_JSON` pour l'environnement `production` (ou au niveau du depot).
Sa valeur est un objet JSON dont les valeurs sont des chaines :

```json
{
  "API_BASE_URL": "https://VOTRE_API",
  "FIREBASE_API_KEY": "VOTRE_CLE_PUBLIQUE",
  "FIREBASE_AUTH_DOMAIN": "VOTRE_PROJET.firebaseapp.com",
  "FIREBASE_PROJECT_ID": "VOTRE_PROJET",
  "FIREBASE_STORAGE_BUCKET": "VOTRE_BUCKET",
  "FIREBASE_MESSAGING_SENDER_ID": "VOTRE_SENDER_ID",
  "FIREBASE_APP_ID": "VOTRE_APP_ID_WEB",
  "FIREBASE_WEB_VAPID_KEY": "VOTRE_CLE_VAPID_PUBLIQUE",
  "STRIPE_PUBLISHABLE_KEY": "VOTRE_CLE_STRIPE_PUBLIQUE_LIVE",
  "MAP_TILE_URL_TEMPLATE": "https://VOTRE_FOURNISSEUR/{z}/{x}/{y}.png",
  "MAP_TILE_USER_AGENT_PACKAGE_NAME": "com.dailycatch.app"
}
```

Remplacer toutes les valeurs. Ces parametres sont publics dans le bundle final.
Ne jamais ajouter de compte de service, de cle Stripe secrete, de mot de passe ou de jeton administrateur.
Les replis de demonstration sont forces a false. Une configuration invalide bloque la livraison.
Configurer les protections de l'environnement production selon les possibilites du compte GitHub avant toute publication externe.

Les builds Android release exigent google-services.json et une configuration de signature ; ils ne font pas partie de ce CD web.
