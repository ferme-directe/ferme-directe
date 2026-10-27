# Ferme Directe

Place de marché B2B entre des fermes et des acheteurs professionnels (restaurateurs, boulangers, épiceries).
L'acheteur décrit son besoin, voit les fermes à proximité qui peuvent le servir, au prix fixé par la ferme,
et commande. La ferme accepte ; le bon de commande part par e-mail aux deux.

Projet final Le Wagon, batch 2312. Équipe : Aurélien, Kahina, Marcio, Marine, Silvère (lead dev).
Demo Day : samedi 21 novembre 2026. Démo intermédiaire : jeudi 5 novembre 2026.

**Le cadrage fait référence** : stories, schéma, trajets, décisions.
https://claude.ai/artifact/TzGPKQYCzh2EyUZ6D8mjt8
Chaque story y a son trajet (route → contrôleur → modèle → tables), recopié dans son issue GitHub.
Une modification de story se fait dans le cadrage ET dans l'issue, jamais dans un seul des deux.

## Comment on travaille

La méthode est dans les skills du dépôt, lus automatiquement par Claude Code :
`.claude/skills/rails-methode` (sous-étapes, recettes, tests, relecture) et
`.claude/skills/rails-controles` (`bin/controles`, `bin/recette`, `bin/ci`).

- **Une story = une issue = une branche = une PR.** Branche créée depuis l'issue (« Create a branch »).
  La PR contient `Closes #N`. Un coéquipier relit. CI verte. Squash merge. Jamais de push sur `main`.
- **Le but est d'apprendre.** Chacun code ses stories, avec Claude s'il le souhaite. L'IA accélère,
  elle ne remplace pas la compréhension : chacun doit pouvoir expliquer chaque ligne de sa PR.
- **Claude propose, l'humain valide.** Claude n'exécute pas de commit, de push ni de fusion sans
  validation explicite, et ne touche jamais aux secrets.
- Commits : Conventional Commits en français (`feat: …`, `fix: …`, `test: …`, `chore: …`, `docs: …`).
- Fin de sous-étape : `bin/controles`, puis `bin/ci` avant d'ouvrir la PR.
- Décisions d'architecture : une note par décision dans `docs/decisions/` (format ADR court).

## Stack et versions

Lire `Gemfile.lock` avant d'écrire du code : il fait foi.

- Ruby 3.3.5 (`.ruby-version`), Rails 8.1, PostgreSQL.
- Template Le Wagon `devise` : Devise, Bootstrap 5.3, Simple Form, Sprockets + sassc, Font Awesome.
  Les écarts avec une application neuve et nos décisions : `docs/decisions/0001-ecarts-du-template.md`.
- Hotwire (Turbo, Stimulus) via importmap.
- Tests : **Minitest et fixtures** (défaut Rails). Pas de RSpec.
- Style : le `.rubocop.yml` du Wagon fait foi. Analyse : Brakeman, bundler-audit.
- Hébergement : Scalingo. Fuseau : `Paris`.

### Les gems du projet, et pourquoi

| Gem | Rôle | Story |
|---|---|---|
| `devise` | Comptes et connexion | toutes |
| `pundit` | Qui a le droit de faire quoi (policies) | 5, 6, 7, 9, 10, 11, 12 |
| `geocoder` | Adresse → coordonnées, distance, rayon (`near`) | 2, 13 |
| `prawn`, `prawn-table` | Bon de commande en PDF | 7, 8 |
| `simple_form` | Formulaires Bootstrap | 1, 4 |
| `letter_opener` (dev) | Ouvre les e-mails dans le navigateur au lieu de les envoyer | 8 |
| `bullet` (dev) | Signale les requêtes N+1 | 2, 9, 12 |
| `rails-i18n`, `devise-i18n` | Textes Rails et Devise en français (à ajouter, issue #20) | toutes |

Ajouter une gem est une décision : on la propose dans une PR à part, avec son pourquoi, après avoir regardé
si Rails le fait déjà.

### Services externes

Principe : gratuit, européen ou natif Rails d'abord. Avant tout service payant ou américain, une courte
étude des alternatives, écrite dans `docs/decisions/`.

- **Géocodage** : API Adresse de l'État (BAN), sans clé (`config/initializers/geocoder.rb`).
  En test, Geocoder est en mode `:test` (`test/test_helper.rb`) : aucun appel réseau.
- **E-mail** : Brevo (français), en SMTP, sans gem. En développement : `letter_opener`.
- **Hébergement** : Scalingo. **Domaine** : Infomaniak.

## Modèle de données

9 tables au cœur de démo : `companies`, `users`, `addresses`, `products`, `listings`, `discount_tiers`,
`favorites`, `orders`, `notifications`. Les tables en réserve du cadrage (`profile_views`, `questions`,
`product_sheets`, `recurrences`) ne sont créées que si une story les demande.

- `companies` : fermes et acheteurs dans la même table (`can_buy`, `can_sell`).
- `listings` : offres ET besoins, distingués par `kind` (`offer` / `need`). Pas de STI.
- `products` : référentiel commun rempli par les seeds. Personne n'ajoute de produit depuis l'interface.
- `orders` : relie un besoin et une offre ; **recopie** produit, label, prix, total au moment de l'accord.
- `notifications` : **polymorphique** (`notifiable`), vers une commande ou vers un besoin (story 13).
- Les « matches » (story 2) ne sont pas une table : une recherche sur `listings`.

### Conventions de données

- **Prix en centimes, entiers** (`unit_price_cents`, `total_cents`). Jamais de float pour de l'argent.
- **Enums en entiers, valeurs en anglais**, avec `validate: true`. Leurs **libellés en français** sont dans
  `config/locales/fr.yml` ; dans une vue : `order.human_enum(:status)`. Jamais « En attente » en dur.
  `test/models/enums_test.rb` fige la liste des valeurs : en changer une passe par le cadrage.
- **Listes fermées en constantes** : `Listing::LABELS`, `SIZES`, `UNITS`, `PRIORITIES`. Formulaires,
  validations et seeds lisent ces constantes.
- Codes postaux en `string` (le zéro de tête).
- Une commande ne disparaît pas avec son entreprise (`dependent: :restrict_with_error`).

## Routes

Les 7 actions CRUD, plus trois routes `member` décidées dans le cadrage (bloc 2) :
`PATCH /orders/:id/accept`, `/decline`, `/cancel`. Chacune est un changement d'état en une ligne qui
délègue au modèle (`@order.accept!`). Leurs actions portent le marqueur `controles: ok route member`.
Aucune autre action hors CRUD sans décision écrite.

Outil de démo : `POST /demo/orders/:order_id/acceptance`, déclaré seulement si `DEMO_MODE` est défini.

## Autorisation

Pundit est branché dans `ApplicationController` : `verify_authorized` (sauf `index`) et
`verify_policy_scoped` (sur `index`). Chaque action appelle `authorize` ou `policy_scope`, et chaque
policy a son test (un accès refusé au moins).

## Textes et langue

Textes visibles par `t()` et `config/locales/fr.yml`, jamais en dur dans une vue, un modèle ou un
contrôleur. `bin/controles` le vérifie. Langue par défaut : français.

## Secrets

Jamais de secret dans le dépôt, un commit, une issue, une PR ou une conversation.
`config/master.key` et `.env` sont ignorés par Git. Les variables attendues sont listées, sans valeur,
dans `.env.example`.

## Données de démo

`bin/rails db:seed` : 15 produits, 15 fermes **fictives** dans des communes **réelles** autour de
Sermaise (4 à 42 km), un acheteur à Sermaise. Idempotent. Comptes : `acheteur@ferme-directe.test`,
`ferme1@…` à `ferme15@ferme-directe.test`, mot de passe `SEED_PASSWORD` (par défaut `motdepasse`, en local).
