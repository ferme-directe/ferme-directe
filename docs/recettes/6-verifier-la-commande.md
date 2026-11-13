# Story 4 — Vérifier la commande (issue #6, écran A03)

Objectif : avant d'envoyer sa commande, l'acheteur voit un récapitulatif (produit, quantité, prix,
remise du palier, total) pour une seule ferme. Rien n'est écrit en base à cette étape : le bouton
« Envoyer » poste vers la création de la story 5, déjà livrée.

Trajet (issue #6) : `GET /needs/:need_id/orders/new?offer_id=` → `OrdersController#new` →
`Order.build_from` (quantité, prix, remise, total) → lit `listings`, `discount_tiers`, n'écrit rien.

## Sous-étapes

- [ ] 4.0 — Remettre la branche au vert
  - Constat du 11 nov. : `bin/rails test` → 100 runs, 5 failures, 5 errors. Cause principale :
    `Listing::UNITS` passé de `pièce` à `pièce(s)` (commit 323efac) ; fixtures, seeds et données
    existantes ont `pièce`, donc les offres deviennent invalides dès qu'on les enregistre.
  - Second constat : `OrdersController#create` ne lisait plus la quantité envoyée (commit dd891a7),
    une quantité nulle créait une commande. Ligne rétablie comme sur `main`.
  - Fichiers : `app/models/listing.rb` (UNITS rétabli), `app/controllers/orders_controller.rb`
    (`create` relit `order_params[:quantity]`), `app/controllers/needs_controller.rb`,
    `app/views/needs/new.html.erb` et `config/routes.rb` (modifications non commitées, retirées,
    voir points ouverts), `docs/a-faire-plus-tard.md` (pluriel des unités).
  - Tests : aucun nouveau ; la suite existante doit repasser au vert.
  - Vérification : `bin/rails test` → 0 failures, 0 errors.
  - Estimation : ~5 lignes

- [ ] 4.1 — La remise du palier dans le modèle
  - Fichiers : `app/models/listing.rb` (`discount_percent_for(quantity)`), `app/models/order.rb`
    (`build_from` applique la remise), `test/models/order_test.rb`, `test/fixtures/discount_tiers.yml`.
  - Technologie : association `discount_tiers` déjà triée par `min_quantity` ; calcul en centimes entiers.
  - Tests :
    - sans palier, total = prix × quantité, remise 0 ;
    - quantité au palier (ex. 10 pour « dès 10 ») → la remise du palier s'applique ;
    - quantité juste en dessous (9) → pas de remise ;
    - deux paliers atteints → le plus avantageux (le plus haut seuil atteint) ;
    - le total est un entier de centimes (arrondi).
  - Vérification : `bin/rails test test/models/order_test.rb`.
  - Effet de bord voulu : la story 5 (`create`) utilise le même `build_from`, donc la commande
    enregistrée porte la même remise que le récapitulatif. Retire la ligne du 31 oct. de
    `docs/a-faire-plus-tard.md`.
  - Estimation : ~60 lignes

- [ ] 4.2 — L'action `new` et ses tests d'intégration
  - Fichiers : `app/controllers/orders_controller.rb` (relecture de `new`, déjà écrite),
    `test/controllers/orders_controller_test.rb`.
  - Tests :
    - l'acheteur ouvre le récapitulatif → 200, produit et total affichés ;
    - ouvrir le récapitulatif n'écrit rien (`assert_no_difference "Order.count"`) ;
    - une autre entreprise sur ce besoin → refusée (accès croisé) ;
    - un visiteur → renvoyé vers la connexion ;
    - une offre fermée → 404.
  - Vérification : `bin/rails test test/controllers/orders_controller_test.rb`.
  - Estimation : ~50 lignes

- [ ] 4.3 — La vue A03
  - Fichiers : `app/views/orders/new.html.erb`, `app/views/orders/_summary.html.erb` (ligne
    « Remise » si remise > 0), `config/locales/fr.yml`, `app/assets/stylesheets/pages/_order.scss`.
  - Technologie : le partial `orders/_summary` de la story 5, prévu « partagé avec la story 4 » ;
    `simple_form_for` vers `need_orders_path(@need)` avec `offer_id` caché ; `format_price`.
  - Tests : couverts par 4.2 (le texte de la remise affiché quand un palier s'applique).
  - Vérification : `bin/dev`, connecté en `acheteur@ferme-directe.test`, un besoin → « Commander »
    sur une carte → le récapitulatif ; « Envoyer » → la page de la commande (story 5).
  - Estimation : ~60 lignes

## Points ouverts

- Unités au pluriel (« 6 pièces ») → option retenue : garder `UNITS` au singulier (valeurs stockées)
  et mettre le pluriel dans `fr.yml` plus tard ; une valeur stockée ne change pas pour l'affichage.
  Noté dans `docs/a-faire-plus-tard.md`.
- `NeedsController#new` (`address_id: current_user.company.addresses`) et le `selected:` de
  `needs/new` → retirés de cette branche : c'est la story 1 (fermée), et `address_id` reçoit une
  liste au lieu d'un identifiant. Si l'adresse par défaut est voulue, petite PR à part.
- Route `show` ajoutée sous `needs/orders` → retirée : la page de commande existe déjà
  (`GET /orders/:id`, story 5) et `create` y redirige.
- Prix dans la vue : `number_to_currency(cents / 100)` fait une division entière (36 / 100 = 0)
  → remplacé par `format_price(cents)`, la convention du projet.
- Arrondi de la remise → `(prix × quantité × (100 − remise) / 100.0).round` : au centime le plus proche.
