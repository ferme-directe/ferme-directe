# 0004 · Des dessins pour les produits et les entreprises

**Date** : 13 novembre 2026 · **Statut** : proposé

## Contexte

Le site manque de visuels : les pages de résultats et de commande sont surtout du texte. Les photos de
produits donnent un rendu inégal (chaque ferme prend les siennes) et demandent un effort aux fermes ;
les photos génériques de banques d'images sonnent faux. Les photos des entreprises (`companies.photos`,
3 photos dans le formulaire d'inscription F-A) sont prévues, mais avec Active Storage et un stockage de
fichiers : hors démo.

## Décision

- **Une icône par produit du référentiel** (15 aujourd'hui), en SVG, dans `app/assets/images/produits/`.
  Le nom du fichier vient du nom du produit (`"Farine d'épeautre".parameterize` → `farine-d-epeautre.svg`).
  Les produits restent dessinés, même quand les entreprises auront leurs photos.
- **Un avatar par entreprise**, dessiné en attendant ses photos :
  - une ferme : le dessin de sa production (6 : poulailler, rucher, céréales, maraîchage, verger,
    laiterie, dans `app/assets/images/fermes/`), d'après sa première offre ;
  - un acheteur : le dessin de son commerce (3 : épicerie, restaurant, boulangerie, dans
    `app/assets/images/acheteurs/`), d'après le début de son code NAF (`companies.naf_code`, déjà en
    base) ; l'épicerie par défaut.
- Même style que le logo : formes simples, contour terre, couleurs naturelles adoucies. Les couleurs
  sont écrites dans les SVG, comme pour le logo : un SVG ne lit pas le SCSS.
- Un seul point d'entrée, `VisualsHelper` : `product_icon(product)`, `company_avatar(company)` et, pour
  la barre du haut, `account_avatar(user)`. Un produit sans icône n'affiche rien ; la page ne plante pas.
- Les visuels sont décoratifs (`alt=""`) : le nom du produit ou de l'entreprise est toujours écrit à côté.

## Conséquences

- Ajouter un produit au référentiel, c'est aussi ajouter son icône ; un test le vérifie
  (`test/helpers/visuals_helper_test.rb`).
- Quand les photos arriveront (Active Storage, avec la story qui l'installe), `company_avatar` affichera
  la photo en priorité et gardera le dessin pour les entreprises sans photo. Les vues ne changent pas ;
  la classe `company-avatar` recadre déjà une photo dans le rond (`object-fit: cover`).
- Aucune migration, aucune gem, aucun service extérieur.
