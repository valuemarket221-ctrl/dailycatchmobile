# DailyCatch MVP Plan

## Objectif

Stabiliser DailyCatch autour d'un parcours inspire de Too Good To Go, mais specialise produits de la mer: decouvrir une offre proche, reserver, payer, recuperer avec un QR/code, puis permettre au partenaire de valider le retrait.

## Priorite 1 - Parcours client

- Splash et redirection auth stables.
- Inscription client et connexion Firebase.
- Home avec offres proches, quantite restante, prix reduit, distance et horaire de retrait.
- Detail boutique/offre avec allergenes, fraicheur, conditions de conservation et heure limite.
- Reservation d'un panier avec confirmation claire.
- QR/code de retrait visible dans les reservations.

## Priorite 2 - Parcours partenaire

- Inscription partenaire separee du client.
- Creation de produits et packs/paniers.
- Gestion stock: disponible, reserve, vendu, expire.
- Liste des commandes a preparer.
- Validation retrait par code ou QR.

## Priorite 3 - Administration

- Validation des partenaires avant publication.
- Vue partenaires: statut, documents, contact, adresse.
- Vue clients et commandes.
- Controle des signalements/remboursements.

## Priorite 4 - Qualite technique

- Supprimer les pages doublons ou prototypes non routees.
- Remplacer les placeholders dans `app_router.dart` par de vraies pages.
- Corriger les lints par flux, pas en vrac.
- Ajouter des tests smoke pour auth, home, reservation et partenaire.
- Verifier les regles Firestore avant toute demo publique.

## Definition d'un MVP presentable

- Un client peut reserver un panier de produits de la mer.
- Un partenaire peut publier un panier et valider un retrait.
- Un admin peut accepter ou refuser un partenaire.
- Les donnees critiques sont persistantes.
- Les tests de base passent et le build web/Android debug compile.
