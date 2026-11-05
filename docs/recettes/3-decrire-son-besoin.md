# Story 1 — Décrire son besoin (issue #3)

Objectif : un acheteur connecté remplit le formulaire A01 (produit, label facultatif, quantité, date,
adresse, rayon, prix max, priorités) en choisissant dans des listes, et son besoin est enregistré dans
`listings` avec `kind: need`. Après l'envoi, il est redirigé vers `/needs/:id/matches` (story 2).

Trajet (cadrage) :
```
affiche le formulaire  GET  /needs/new  → NeedsController#new
  lit   products (la liste), addresses de l'entreprise
« Voir les fermes »    POST /needs      → NeedsController#create
  modèle  Listing, kind: need, validations
  écrit   listings (1 ligne)
  puis    redirige vers /needs/:id/matches
```

État de départ (3 nov.) : un premier jet existe, non commité (contrôleur, policy, vue, prix en euros
dans le modèle, traductions). Les sous-étapes ci-dessous le reprennent et ajoutent les tests.

## Sous-étapes

- [ ] 1.1 — Qui a le droit : la policy et le contrôleur, avec leurs tests
  - Fichiers : `app/policies/listing_policy.rb`, `app/controllers/needs_controller.rb`,
    `test/policies/listing_policy_test.rb`, `test/controllers/needs_controller_test.rb`
  - Technologie : Pundit (`authorize`), `params.expect` (Rails 8.0+, notre version : 8.1.4).
  - Corrections du premier jet :
    - `ListingPolicy#create?` répond `true` à tout le monde : un besoin n'est permis qu'à un compte dont
      l'entreprise achète (`user.company&.can_buy?`) ; `new?` hérite de `create?` (ApplicationPolicy).
    - `before_action :authenticate_user!` est déjà dans `ApplicationController` : on le retire ici.
    - `form_options` tourne avant `authorize` : un compte sans entreprise (`company` est facultative)
      plante sur `nil.addresses` au lieu d'être refusé. On appelle `form_options` après `authorize`.
    - `params.require(...).permit(...)` devient `params.expect(listing: [...])`.
  - Tests :
    - policy : un acheteur peut créer un besoin ; une ferme non ; un compte sans entreprise non.
    - contrôleur : un visiteur est renvoyé vers la connexion ; une ferme qui ouvre `/needs/new` est
      refusée (redirection + message) ; l'acheteur voit le formulaire (200) ;
      un besoin complet crée une ligne `kind: need` rattachée à l'entreprise de l'acheteur et redirige vers
      `/needs/:id/matches` ; un besoin incomplet ne crée rien et répond 422 ;
      un `company_id` envoyé dans le formulaire est ignoré ; l'adresse d'une autre entreprise est refusée
      (accès croisé).
  - Vérification : `bin/rails test test/policies test/controllers/needs_controller_test.rb` vert ;
    connectée en `ferme1@ferme-directe.test`, `/needs/new` renvoie à l'accueil avec un message.
  - Estimation : ~130 lignes

- [ ] 1.2 — Le prix maximum saisi en euros, stocké en centimes
  - Fichiers : `app/models/listing.rb`, `test/models/listing_test.rb`
  - Technologie : un attribut virtuel (lecteur `max_price` / écrivain `max_price=`) devant la colonne
    `max_price_cents`.
  - Correction du premier jet : `max_price_cents / 100.0` est un float ; on passe par `BigDecimal`
    (`max_price_cents.to_d / 100`), règle du projet « jamais de float pour de l'argent ».
  - Tests : « 0.40 » saisi donne 40 centimes (le champ `number` envoie toujours un point) ; « 1.5 » donne 150 ; un champ vide donne `nil` ;
    40 centimes se relisent 0.4 ; « 0 » est refusé par la validation existante.
  - Vérification : `bin/rails test test/models/listing_test.rb` vert.
  - Estimation : ~35 lignes

- [ ] 1.3 — Le formulaire A01
  - Fichiers : `app/controllers/needs_controller.rb` (préparation des listes seulement),
    `app/views/needs/new.html.erb`, `config/locales/fr.yml`, `test/controllers/needs_controller_test.rb`
  - Technologie : Simple Form (`f.association … as: :grouped_select`, `as: :check_boxes`), traductions
    `simple_form.labels`, `content_for :title`.
  - Corrections du premier jet :
    - `f.input :product` envoie `listing[product]`, pas `listing[product_id]` : le produit n'arrive jamais
      au contrôleur. On passe par `f.association :product`.
    - Le regroupement par catégorie (`group_by`) se fait dans le contrôleur, pas dans la vue.
    - Les priorités sont écrites en HTML à la main : pas de case cochée conservée après une erreur,
      libellés anglais (`Distance`, `Price`) et `aria-label="Priorités"` en dur. On passe par
      `f.input :priorities, as: :check_boxes`, libellés lus dans `activerecord.attributes.listing/priorities`
      (déjà présents dans `fr.yml`).
    - `label: "dans un rayon de (km)"` en dur dans la vue : retiré, la clé existe dans `fr.yml`.
    - Les libellés sont rangés sous `simple_form.labels.listing.new` : après une erreur, la vue est
      rendue par l'action `create` et Simple Form ne les trouve plus. On les range sous
      `simple_form.labels.listing`.
    - Les `<div>` sont mal imbriquées (la `div.need-form` se ferme avant la fin du `simple_form_for`) ;
      `class="tag"` sert à autre chose dans la charte (étiquettes). On remet la structure à plat.
    - Coquille : « addresse ».
    - Titre de l'onglet par `content_for :title`.
  - Tests (contrôleur) : le formulaire liste les produits ; il propose les adresses de l'entreprise de
    l'acheteur et pas celles d'une autre ; après un envoi incomplet, le message d'erreur est affiché à
    côté du champ concerné et les priorités cochées le restent.
  - Vérification : `bin/dev`, connectée en `acheteur@ferme-directe.test`, `/needs/new` → produits groupés
    par catégorie, adresse de Sermaise, priorités en français ; envoyer sans quantité → message rouge
    sous « Quantité », les autres champs restent remplis.
  - Estimation : ~110 lignes

- [ ] 1.4 — La PR
  - `bin/ci` vert, corps de PR au format de fin de sous-étape, `Closes #3`, un coéquipier relit.

## Points ouverts

- La redirection mène à `/needs/:id/matches`, dont l'action est vide (story 2) : sans `policy_scope`,
  la page lève `Pundit::PolicyScopingNotPerformedError`. → option retenue : on garde la redirection
  (c'est le trajet du cadrage), le test vérifie la redirection sans la suivre, et on prévient la
  personne de la story 2.
- `ListingPolicy` servira aussi aux offres (story 4, `can_sell`). → option retenue : `create?` ne traite
  que le besoin (`record.need?` et `can_buy?`) avec un commentaire ; la story 4 ajoutera le cas offre.
- Le formulaire ne propose que les adresses `delivery` alors que le libellé dit « Livraison ou Retrait ».
  → option retenue : on garde `delivery` (un acheteur se fait livrer ; le retrait se choisit à la
  commande, story 4-5) et le libellé devient « Adresse de livraison ». À confirmer avec l'équipe.
- Le message « Vous n'avez pas accès à cette page. » est en dur dans `ApplicationController`. Hors
  périmètre de la story → ligne dans `docs/a-faire-plus-tard.md`.
