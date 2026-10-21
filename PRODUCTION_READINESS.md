# Mobile : passage aux services reels

## Modifications du 20 octobre 2026

- Client HTTP reel par defaut, aucune selection automatique du DemoClient.
- Mode demo et replis fictifs desactives, y compris avec les anciens dart-defines.
- Comptes et jetons locaux integres retires de LocalAuthSession ; authentification Firebase requise.
- Catalogues StoreRepository et RescuedProductRepository : API vide = catalogue vide ; erreur API = erreur, jamais un catalogue invente.
- Donnees fictives getMockStores/getMockProducts retirees.
- Retrait du doublement artificiel du prix original des produits sauves.
- Photos des produits sauves chargees depuis le backend ; photo manquante = pictogramme neutre.
- Ecran des produits sauves : erreur reseau et bouton de reessai.
- Ancien script de fabrication de l'APK demo desactive.

## Limites : pas encore une livraison production

### Complement du 21 octobre 2026

- Carte : suppression des boutiques fictives de secours, des positions generees et des notes/nombres d'avis calcules depuis les identifiants.
- Seules les offres avec latitude/longitude presentes, finies et dans les limites geographiques peuvent etre placees sur la carte.
- Catalogue : coordonnees et note absentes restent nulles ; aucune image de produit de remplacement ni distance "Proche" sans mesure.
- API product-offers enrichie avec storeAddress, storeRating et storeReviewCount issus de PostgreSQL.
- Moyenne des avis des commandes picked_up, chaque avis compte une seule fois par boutique meme avec plusieurs articles.
- Carte raccordee aux adresses et avis API ; le catalogue utilise la note API et les produits sauves utilisent l'adresse API.
- Verification locale : analyse Flutter sans probleme ; 83 tests mobiles passes, 3 ignores ; 110 tests backend passes, aucun ignore ; smoke API et persistance apres redemarrage valides.
- Ces tests n'impliquent aucun paiement fournisseur ni notification push reelle. Le parcours visuel sur appareils physiques reste a valider.

Il subsiste du code de demonstration inactif et des valeurs de presentation a auditer ecran par ecran (notes, coordonnees, horaires, estimations et images de remplacement). La desactivation des replis ne prouve pas que tous les champs affiches correspondent deja au contrat API.

La base locale existante peut contenir des seeds de test. Ils n'ont pas ete supprimes automatiquement : verifier leur provenance avant toute migration, sans effacer les comptes ou commandes utiles. Une nouvelle base de production doit recevoir les migrations, pas les seeds de demonstration.

Les favoris sont encore stockes localement et ne prouvent pas une synchronisation entre appareils. Les essais de routes avec HTTP simule en test ne sont pas des tests E2E des fournisseurs reels.

## Conditions restantes

1. URL HTTPS du backend accessible depuis les telephones ; localhost ne convient pas a un APK distribue.
2. Base de production provisionnee, migrations, sauvegardes/restauration et supervision validees.
3. Applications Android/iOS enregistrees dans Firebase avec les identifiants correspondant au build et inscription Email/Password activee.
4. Remplacement de la cle de service Firebase partagee precedemment ; jamais de cle privee dans Flutter.
5. Stripe configure cote serveur/mobile, webhooks et remboursements testes en sandbox avant activation live.
6. Push verifies sur appareils physiques, au premier plan et en arriere-plan.
7. Fournisseur de carte configure, permissions et refus de localisation testes.
8. Audit des valeurs de presentation restantes, persistance et isolation entre comptes.
9. Signature de distribution, build release et essais client/vendeur/admin sur appareils physiques.

Les vraies boutiques, photos, offres et commandes doivent venir des vendeurs et clients enregistres. Aucun contenu de demonstration ne doit etre presente comme reel.

L'ancien `DailyCatch-Demo.apk` n'a pas ete reconstruit et n'est pas un APK de production.
