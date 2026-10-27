---
name: rails-controles
description: Contrôles automatiques de fin de sous-étape pour un projet Rails et journal des recettes en ajout seul — valeurs en dur, échappement désactivé, variables d'instance dans les partials, méthodes publiques hors REST, paramètres autorisés, autorisation Pundit, sélecteurs Bootstrap redéfinis, tests, puis une ligne JSON par recette écrite par le script bin/recette, jamais par l'IA. À utiliser quand une sous-étape se termine, quand l'utilisateur dit « lance les contrôles », « autocontrôles », « recette », « journal des tests », « bin/ci », ou pour installer bin/controles, bin/recette, l'étape config/ci.rb et le workflow de CI dans un projet, seul ou en équipe. Complète le skill rails-methode. Rédigé en français, commandes et champs du journal compris.
---

# Contrôles de fin de sous-étape et journal des recettes

Ces contrôles existent parce que ce sont les erreurs qui reviennent le plus souvent dans du code généré, et qu'un `grep` de dix secondes vaut mieux qu'une découverte en production. Chaque contrôle doit remonter vide. S'il remonte quelque chose, corrige avant de rendre la main, ou déclare l'exception **dans le code** avec le marqueur `controles: ok <raison>` (en commentaire Ruby, ERB ou CSS sur la ligne concernée ; pour une action hors CRUD, sur la ligne au-dessus du `def`, RuboCop refusant un commentaire sur la ligne du `def`) : le script ignore ces lignes, et la raison reste lisible par le prochain relecteur.

Le journal des recettes existe parce que « les tests passent » n'est une preuve que si une machine l'a écrit, avec la commande exacte, sa sortie exacte, son code de sortie et le commit sur lequel elle a tourné.

Trois outils, trois fichiers de ce skill :

| Outil | Source | Rôle |
|---|---|---|
| `bin/controles` | `scripts/controles.sh` | les `grep` et analyses de fin de sous-étape ; sort en erreur si un contrôle échoue |
| `bin/recette` | `scripts/recette.rb` | lance les vérifications, capture tout, ajoute une ligne à `docs/journal/recettes.jsonl` |
| étape `bin/ci` | `assets/ci-step.rb` | branche `bin/controles` dans `config/ci.rb` (Rails 8.1+) pour un seul point de contrôle, local et distant |

Un outil par vérification, un seul endroit chacun : RuboCop et Brakeman ne sont pas relancés par `bin/controles`, ils ont leur étape dans `config/ci.rb` et dans la liste par défaut de `bin/recette`.

## Installation dans un projet

C'est une sous-étape en soi, à faire valider par la recette comme les autres. Tu proposes les commandes, l'utilisateur les tape :

```bash
cp <skill>/scripts/controles.sh bin/controles && chmod +x bin/controles
cp <skill>/scripts/recette.rb   bin/recette   && chmod +x bin/recette
```

Puis, si le projet a `config/ci.rb` (Rails 8.1+), ajouter la ligne de `assets/ci-step.rb` juste après l'étape Brakeman. Les deux scripts sont versionnés avec le projet : ils font partie de sa méthode, pas de l'outillage personnel.

**En équipe**, deux lignes de plus dans la même sous-étape :

- `.gitattributes` à la racine : `docs/journal/recettes.jsonl merge=union`. Le journal est écrit depuis plusieurs branches ; sans cette ligne, chaque fusion de PR produit un conflit sur un fichier qu'on n'a pas le droit d'éditer à la main. Avec elle, Git concatène les lignes des deux côtés.
- Les skills `rails-methode` et `rails-controles` copiés dans `.claude/skills/` du dépôt, pour que le Claude Code de chaque membre applique la même méthode.

**Projet né d'un template** : vérifie si le template a supprimé `.github/workflows/ci.yml` (certains le font) ou remplacé `.rubocop.yml`. Sans workflow, la CI distante n'existe pas : en Rails 8.1+, un workflow minimal qui lance `bin/ci` suffit (Ruby via `ruby/setup-ruby`, un service Postgres, puis `bin/ci`), et il doit lancer les mêmes commandes que le local, dans le même ordre. Si le template a désactivé les fixtures (`config.generators … fixture: false`), le contrôle « Tests » le signale : c'est une décision à écrire dans le `CLAUDE.md`, pas un défaut à corriger en silence.

Vérifie avant de rendre la main : `bin/controles` doit afficher une liste de ✓ et finir par `N OK, 0 à traiter` ; `bin/recette --help` doit afficher l'usage. Sur macOS, deux contrôles exigent GNU grep (`brew install grep`) ; sans lui, ils s'affichent « non exécuté » plutôt que verts à tort.

## bin/controles — ce que chaque contrôle attrape

Le script détecte la stack (Sass, Bootstrap, Tailwind ou CSS pur ; Stimulus ; Pundit ; présence de bundler-audit) et n'applique que les contrôles qui ont un sens. Trois types de lignes :

- `✓` / `✗` : le contrôle doit remonter vide (ou sortir en code 0). Un `✗` est à traiter, et fait échouer `bin/ci`.
- `◦` : une liste à relire ligne par ligne, sans jugement automatique possible.

### Vues

- **`style=` ou `<style>` dans une vue** : une règle CSS qu'aucun fichier de style ne connaît. Elle échappe aux variables, au mobile d'abord et à toute modification globale. Les vues de mailers sont exclues : les clients mail imposent les styles inline.
- **Gestionnaire JavaScript inline** (`onclick=`, `onchange=`…) : un comportement hors Stimulus, invisible dans `app/javascript/`, impossible à tester ni à retrouver.
- **`html_safe` / `raw`** : Rails échappe tout ce qui s'affiche ; ces deux appels désactivent la protection. Chaque occurrence est un point d'injection potentiel : soit on la retire, soit on la justifie par `controles: ok <d'où vient le contenu et pourquoi il est sûr>`.
- **Variable `@…` dans un partial** : un partial qui lit `@record` dépend en silence du contrôleur qui l'appelle et casse dès qu'on le réutilise ailleurs. Il reçoit des `locals`, rien d'autre. Les adresses e-mail dans une chaîne ne sont pas comptées.
- **Texte visible hors `t()`** : ne tourne que si le projet traduit déjà ses vues (au moins un `t(` dans `app/views/`). Un texte d'au moins treize caractères directement entre deux balises, sur une seule ligne, est un texte que personne ne modifiera sans toucher au code. Le motif ne voit ni les textes commençant par une minuscule ni ceux qui occupent leur propre ligne entre `<p>` et `</p>` : relis aussi à l'œil.

### Ruby

- **`Time.now` / `Date.today`** : ignorent le fuseau configuré dans l'application. `Time.current` et `Date.current` le respectent.
- **Méthodes de même nom dans modèles, helpers et lib** (`◦`) : deux `def published?` dans deux modèles sont souvent légitimes (polymorphisme), parfois une logique réécrite. La liste est à relire, pas à faire taire. Le vrai doublon — deux `def` du même nom dans la même classe — est attrapé par RuboCop (`Lint/DuplicateMethods`).

### Feuilles de style, selon la stack

Le principe est le même partout : **une couleur, une taille, un espacement n'existent qu'à un seul endroit.** Ce qui change, c'est où cet endroit se trouve.

- **Sass** (`.scss`, avec ou sans framework) : aucune couleur hexadécimale hors des fichiers de variables. Un framework CSS se personnalise par ses variables, jamais en recopiant ses sélecteurs. Compilation vérifiée si `dartsass-rails` est présent (avec Sprockets et `sassc-rails`, la compilation se fait à la requête : une erreur Sass apparaît au premier rechargement de page, d'où l'importance de recharger souvent). Aucun `!important`.
- **Bootstrap** (gem `bootstrap`, donc Sass) : les contrôles Sass, plus une liste (`◦`) des sélecteurs du framework redéfinis dans les feuilles du projet (`.btn`, `.navbar`, `.card`, `.form-control`, `.modal`…). Chaque ligne est soit une variable Sass de Bootstrap à utiliser à la place (`$primary`, `$btn-border-radius`, `$card-spacer-y`…), déclarée avant `@import "bootstrap"`, soit une exception justifiée. Les classes du projet en BEM (`.card__title`) ne sont pas comptées.
- **Tailwind** (`tailwindcss-rails` v3 ou v4, ou via `cssbundling-rails`) : les couleurs sont des classes du thème. Une valeur arbitraire `bg-[#B5533C]` dans une vue est l'équivalent d'une couleur en dur. Un bloc d'interface répété est un partial, pas vingt listes de classes identiques : c'est ce que recommande la documentation de Tailwind elle-même, plutôt que `@apply`.
- **CSS pur** : les couleurs vivent dans des propriétés personnalisées (`--couleur`) déclarées dans `:root` ; tout hexadécimal ailleurs est un écart.

Le contrôle ne voit que l'hexadécimal (`#RGB` à `#RRGGBBAA`) ; `rgb()`, `hsl()` et les couleurs nommées passent entre les mailles, relis-les à l'œil. Le motif des fichiers autorisés à contenir des couleurs se règle par la variable `CONTROLES_VARIABLES` (défaut : `_variables`, `_colors`, `_tokens`, `stylesheets/config/`, le fichier de thème Tailwind). Si le projet range ses variables ailleurs, note-le dans le `CLAUDE.md` et exporte la variable dans `bin/controles`.

### Stimulus

- **Contrôleur de plus de 30 lignes de code** (commentaires et lignes vides exclus, `.js` et `.ts`) : il fait plus d'une chose. Un contrôleur = un comportement.

### Contrôleurs

- **Paramètres autorisés** (`◦`) : la liste des `permit(` et `expect(`, à relire un par un. Vérifie qu'aucun champ réservé n'est autorisé pour un rôle qui n'y a pas droit (`status`, `role`, `admin`, un identifiant de rattachement, un montant) et que deux rôles n'ont pas la même liste. C'est la faille la plus courante en Rails.
- **Méthode publique hors des sept actions CRUD** : toute méthode définie avant `private` qui n'est pas `index show new create edit update destroy` est soit une action hors CRUD (donc une ressource qui manque, ou une route `member` décidée dans le `CLAUDE.md`, à marquer `controles: ok route member, <décision>` sur la ligne du `def`), soit une méthode utilitaire devenue accessible par URL.
- **Valeur interpolée dans une requête** : `where("… #{…}")`, `order(params[…])`, `find_by_sql` avec interpolation : chaque occurrence est une injection SQL possible. Les paramètres de requête (`?`, `where(colonne: valeur)`) remplacent l'interpolation ; un tri demandé par l'URL passe par une liste blanche.
- **Relation parcourue sans borne** (`◦`) : la liste des `.all` et des `.each` sur une relation dans les contrôleurs et les vues, à relire : chaque liste affichée a une pagination ou un `limit`, chaque traitement de masse un `find_each`.

### Robustesse

- **Erreur avalée** : `rescue` sans classe d'exception, `rescue Exception`, `rescue nil`, ou un `rescue` dont le bloc est vide. Chaque occurrence cache une erreur qui reviendra ailleurs ; on rattrape une exception précise et on la journalise, ou on la laisse remonter.
- **Raccourci qui saute les validations** : `update_attribute`, `update_column(s)`, `save(validate: false)`, `skip_callback`. Interdits sauf `controles: ok <raison>` sur la ligne.
- **`has_many` sans `dependent`** (`◦`) : la liste des associations qui ne disent pas ce qui arrive aux enfants à la suppression. Chacune reçoit `dependent: :destroy`, `:restrict_with_error` ou `:nullify` selon la règle métier.
- **Callbacks à effet de bord** (`◦`) : les `after_*` / `before_*` de modèle qui mentionnent un mailer, un job, un service ou un autre modèle. À relire : un effet de bord part d'une méthode métier nommée, pas d'un callback.

### Autorisation (si Pundit est installé)

- **`verify_authorized` et `verify_policy_scoped` en `after_action` dans `ApplicationController`** : c'est ce qui transforme un `authorize` oublié en erreur visible en développement au lieu d'une faille silencieuse en production. Les deux lignes doivent exister ; `except:` / `only:` sont libres.
- **Contrôleurs sans `authorize` ni `policy_scope`** (`◦`) : la liste des contrôleurs de ressource qui n'appellent ni l'un ni l'autre. Chacun doit en avoir un, ou porter un `skip_authorization` / `skip_policy_scope` avec un commentaire disant pourquoi (pages publiques, par exemple). `application_controller` et `pages_controller` sont exclus.

Ces contrôles voient la présence d'un appel, pas sa justesse : la règle « un autre utilisateur ne peut pas voir ni modifier cette ressource » se prouve par un test d'intégration, pas par un `grep` (skill `rails-methode`, test d'accès croisé).

### Tests

- **Fixtures désactivées par les générateurs** (`◦`) : signalé quand `config/application.rb` porte `fixture: false` (c'est le cas de certains templates). Minitest avec fixtures est le défaut de Rails ; y renoncer est une décision à écrire dans le `CLAUDE.md`, avec ce qui les remplace.
- **`skip` sans commentaire daté** (`◦`) : un test ignoré sans raison datée est un test désactivé en douce ; le compteur `skips` du journal sert à voir s'il grimpe.

### Avant mise en ligne (`--prod`)

À lancer avant le premier déploiement, puis à chaque montée de version :

- **Secret en dur** : une chaîne d'au moins huit caractères affectée à `password`, `secret`, `api_key` ou `token` hors de `credentials`, des fichiers de traduction et des `ENV[…]`.
- **Journaux citant un champ personnel** (`◦`) : les lignes de journal qui mentionnent un e-mail, un téléphone, une adresse ou un nom. À relire : aucune ne doit écrire la valeur.
- **`filter_parameters`** (`◦`) : à relire chaque fois qu'un champ personnel a été ajouté.
- **bundler-audit** (`bin/bundler-audit check --update`, la forme qui lit `config/bundler-audit.yml`) : failles connues dans les gems installées.

### Ce qui n'est pas ici, et pourquoi

- **Brakeman** et **RuboCop** : une étape chacun dans `config/ci.rb` et dans `bin/recette`. Le binstub `bin/brakeman` généré par Rails ajoute `--ensure-latest` : une recette rouge sur Brakeman peut vouloir dire « mets Brakeman à jour », pas « code vulnérable » — lis le `.log`. Un avertissement qu'on décide d'ignorer se documente dans `config/brakeman.ignore`, avec la raison.
- **Requêtes en cascade** : pas de `grep` possible ; propose `bullet` dans le groupe `development` du `Gemfile`. C'est une gem ajoutée, donc une décision à faire valider, pas à glisser.

## bin/recette — le journal des recettes

### Quand il tourne

**Après le commit du code de la sous-étape.** Le champ `commit` de la ligne désigne la version testée ; lancé avant le commit, il pointerait toujours vers la version précédente. L'ordre est donc : commit du code → `bin/recette` → commit du journal (« Journal : recette N.M »). Si des fichiers hors `docs/journal/` sont modifiés au moment du lancement, la ligne porte `modifications_non_commitees: true` et le script le dit : cette ligne vaut moins qu'une autre.

### Ce qu'il fait

`bin/recette E3.2 "Formulaire : consentement obligatoire"` :

1. lance dans l'ordre `bin/controles`, `bin/rubocop`, `bin/brakeman` (ceux qui existent) puis `bin/rails test -v` — ou les commandes de `config/recette.txt` s'il existe, une par ligne, chacune interprétée par `sh` ; `--system` ajoute `bin/rails test:system` dans les deux cas ;
2. tourne avec `CI=true`, comme `bin/ci` : en Rails 8.1 l'environnement de test charge alors toute l'application (eager loading), plus lent et plus strict qu'un `bin/rails test` tapé à la main — un test qui passe au terminal et échoue dans la recette vient souvent de là ;
3. capture pour chaque commande la commande exacte, le code de sortie, la durée, et la sortie intégrale dans `docs/journal/sorties/<horodatage>_E3.2/NN-commande.log`, avec masquage de ce qui ressemble à un mot de passe ou un jeton ;
4. lit la ligne de résumé de Minitest (`N runs, N assertions, N failures, N errors, N skips`) ;
5. ajoute **une ligne** à `docs/journal/recettes.jsonl` : sous-étape, description, date, commit, branche, modifications non commitées, versions de Ruby et Rails, commandes et résultats, statut `vert` ou `rouge` ;
6. sort en erreur si une commande a échoué.

`bin/recette valider E3.2 "Prénom"` ajoute une ligne de validation humaine liée à la dernière recette verte de cette sous-étape, et refuse si elle est rouge. Machine verte et validation humaine sont deux choses différentes : c'est la règle « on ne valide rien qu'on ne puisse expliquer ». En équipe, le prénom est celui du relecteur de la PR, pas de l'auteur.

`bin/recette resume` affiche l'historique en tableau Markdown, pour la documentation du projet.

### Les trois règles qui lui donnent sa valeur

1. **Chaque sous-étape se termine par `bin/recette`.** Pas par une phrase disant que les tests passent.
2. **Le journal n'est jamais écrit ni modifié à la main, ni par l'IA.** Il est en ajout seul ; une correction est une nouvelle ligne. Rien dans le fichier n'empêche techniquement une retouche : la garantie est l'historique Git, où toute modification d'une ligne existante se voit. C'est pour cela que `docs/journal/` est versionné.
3. **Une entrée verte ne dispense de rien.** Un test vert à l'étape 3 peut casser à l'étape 8 : chaque recette relance toute la suite. Le journal sert à l'inverse : retrouver la dernière version où tout était vert (`git bisect` depuis ce commit), repérer les tests instables, voir les `skips` qui grimpent ou une durée qui explose.

### Ce que tu fais, et ce que tu ne fais pas

- Tu lances `bin/recette` (après le commit), tu colles sa sortie dans le résumé de fin de sous-étape, tu signales la mention « modifications non commitées » si elle apparaît.
- Tu ne rédiges jamais toi-même une ligne de `docs/journal/recettes.jsonl`, et tu n'en modifies jamais une.
- Si une commande est rouge, tu lis le fichier `.log` correspondant avant de proposer une correction — pas la ligne de résumé, la sortie.
- `-v` sur `bin/rails test` liste chaque test par son nom : c'est ce qui permet, plus tard, de juger si un test « n'était pas allé assez loin ». Le commit de l'entrée pointe vers le code des tests à ce moment-là.
- Les tests tournent sur des données d'exemple (fixtures), jamais sur des données réelles : rien de personnel ne doit pouvoir se retrouver dans un `.log`.

## Branchement dans bin/ci

Depuis Rails 8.1, `bin/ci` lance les étapes définies dans `config/ci.rb` — installation, RuboCop, bundler-audit, audit d'importmap ou de yarn selon la stack, Brakeman, `bin/rails test`, rechargement des seeds en test — en local comme en intégration continue, avec `CI=true`. `bin/controles` y entre comme une étape de plus, après Brakeman (`assets/ci-step.rb`) : un seul point de contrôle, le même partout, et un `bin/ci` rouge dès qu'un contrôle échoue. Le fichier généré est une suite plate de `step` ; `group` et `parallel:` ne sont pas encore dans la version publiée.

L'étape « Tests: Seeds » (`db:seed:replant` en test) fait partie du défaut : des seeds qui ne se rejouent pas sont un `bin/ci` rouge, ce qui est voulu — une démo repose dessus.

Les tests système restent commentés dans `config/ci.rb` tant qu'aucun parcours critique n'en a ; on les active dès le premier, pour un parcours, pas pour chaque page.

Avant Rails 8.1, il n'y a pas de `bin/ci` : `bin/recette` joue ce rôle en local, et le fichier de CI distant lance les mêmes commandes dans le même ordre.

## Ce que ces contrôles ne font pas

Ils ne remplacent ni les tests, ni la relecture humaine, ni la lecture des paramètres autorisés un par un. Ils attrapent les erreurs mécaniques, celles qu'on fait en répétant, pour que la relecture humaine se concentre sur la logique. Un `bin/controles` tout vert sur un code que l'utilisateur ne sait pas expliquer n'est pas une sous-étape terminée.
