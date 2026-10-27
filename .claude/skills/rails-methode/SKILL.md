---
name: "rails-methode"
description: Méthode de développement Rails par sous-étapes courtes, recettées, testées et contrôlées, pour produire avec une IA un code que l'utilisateur maîtrise et peut expliquer — seul ou en équipe (une story = une issue = une branche = une PR). À utiliser dès qu'on démarre, reprend ou fait avancer un projet Rails — écrire une recette, exécuter une sous-étape, écrire les tests, relire une PR, clore une session — et dès que l'utilisateur parle de recette, sous-étape, étape, brique, story, itération, autocontrôle ou demande du code Rails, même sans nommer la méthode. Les contrôles automatiques et le journal des recettes sont dans le skill rails-controles.
---

# Méthode de développement Rails par sous-étapes

Cette méthode part d'un constat : personne ne peut relire cinq cents lignes générées d'un coup et savoir si elles sont justes. On peut relire cent cinquante lignes, les comprendre, et dire oui ou non. Tout ce qui suit découle de cette limite.

Ce skill dit *comment on travaille* ; le `CLAUDE.md` du projet dit *ce qu'on construit* (stack, versions, modèle de données, décisions prises). Rien de ce qui est propre à un projet ne doit entrer ici : si une règle ne vaut que pour un projet, elle va dans son `CLAUDE.md`. Les contrôles automatiques (`bin/controles`), le journal des recettes (`bin/recette`) et le branchement dans `bin/ci` sont décrits dans le skill `rails-controles`.

Avant de générer la moindre ligne, lis `CLAUDE.md` et `Gemfile.lock` : la version de Rails et les gems installées décident de ce qui est disponible (`params.expect` n'existe qu'à partir de Rails 8.0, `bin/ci` qu'à partir de 8.1). Ne devine jamais une version.

**Projet né d'un template** (template d'école, d'entreprise, `rails new -m …`) : avant la première story, lis ce que le template a changé par rapport à une application neuve, et consigne chaque écart dans le `CLAUDE.md` avec la décision prise (on garde, on revient au défaut, pourquoi). Les points qui changent le plus souvent : générateurs (`config.generators` — tests, fixtures, helpers, assets), fichier `.rubocop.yml` remplacé, workflow de CI supprimé, pipeline d'assets remplacé (Sprockets et sassc au lieu de Propshaft et dartsass), gems ajoutées, modèle `User` et vues déjà générés. Un écart non consigné est redécouvert par chaque membre de l'équipe, à ses frais.

## La règle qui gouverne tout

**L'utilisateur ne valide rien qu'il ne puisse expliquer à voix haute.**

C'est une contrainte pour toi plus que pour lui. Chaque bloc de code est accompagné de ce qu'il fait et pourquoi, au niveau où l'utilisateur en est. Si tu ne peux pas l'expliquer simplement, le bloc est trop gros ou trop malin : découpe-le ou simplifie-le. Quand tu emploies une notion Rails qu'il n'a peut-être pas encore vue, explique-la en deux ou trois phrases avec un exemple tiré du projet.

Dans un fichier sorti d'un générateur Rails puis modifié, dis ce qui vient du générateur et ce qui a été écrit : sans cette distinction, un lecteur surestime la complexité de ce qu'il a à comprendre.

Quand l'équipe apprend en construisant, la relecture est un temps d'apprentissage, pas une formalité : le résumé de fin de sous-étape dit par quoi commencer la relecture, quelle notion Rails chaque fichier met en œuvre, et renvoie au guide officiel correspondant.

Corollaire : **tu proposes, il exécute.** Tu n'exécutes jamais un commit, un push, une migration en production, une installation de dépendance, une commande destructive (`db:drop`, `db:reset`). Tu annonces la commande, il la tape. C'est plus lent, et c'est ce qui fait qu'il maîtrise son projet à la fin.

Les erreurs se transmettent telles quelles, copiées depuis le terminal, jamais résumées — dans les deux sens.

## Le cycle

### 1. La recette avant le code

Avant toute étape, écris une recette dans `docs/recettes/etape-N.md` (gabarit en fin de skill ; en équipe, une recette par story, voir plus bas) :

- l'objectif de l'étape en deux phrases ;
- les sous-étapes, chacune avec une case à cocher ;
- pour chaque sous-étape : les fichiers touchés, la technologie employée, **les tests à écrire**, ce que l'utilisateur vérifie à la fin, une estimation en lignes ;
- les points où tu hésites ou vois plusieurs options, avec celle que tu prends et pourquoi.

Une sous-étape fait **150 lignes au maximum**, tests compris, réparties sur plusieurs fichiers si besoin. C'est ce qu'un relecteur attentif absorbe en une passe sans décrocher ; au-delà, il valide sans lire. Si une sous-étape dépasse, découpe-la.

La recette est soumise **avant** d'écrire la moindre ligne. Si l'utilisateur demande directement du code, réponds d'abord par la recette. Il la relit, la corrige, puis dit « exécute la sous-étape N.M, et seulement elle ».

La recette écrite avant le code devient la liste des cas de test : chaque ligne « ce que l'utilisateur vérifie » qui touche un modèle, un contrôleur ou une règle de gestion a son test automatisé dans la sous-étape.

### 2. Les tests avec le code, jamais après

Toute sous-étape qui crée ou modifie un modèle, un contrôleur ou une règle de gestion inclut ses tests dans les 150 lignes. Pas dans une sous-étape ultérieure : dans la même.

Écrire les tests après coup sur un code conçu sans eux est difficile et se fait rarement. Les écrire en même temps est naturel et rend le code plus simple, parce qu'on cherche ce qu'on va tester. C'est le seul endroit où le retard se paie en refonte plutôt qu'en retouche.

Un test, c'est une phrase : « quand je fais ça, j'attends ça ». Trois à cinq tests par modèle suffisent au début : le cas normal, les cas limites, ce qui doit échouer.

**La pyramide, telle que Rails l'organise** (Minitest et fixtures par défaut, ne pas remplacer sans décision écrite dans le `CLAUDE.md` ; si un template a désactivé les fixtures, c'est une de ces décisions) :

| Niveau | Dossier | Ce qu'il vérifie | Quand |
|---|---|---|---|
| Unitaire | `test/models` | une règle isolée, sans requête web | chaque validation, scope, méthode métier |
| Intégration | `test/controllers`, `test/integration` | une requête complète : route, contrôleur, base, réponse | chaque action, et surtout ce qu'un visiteur ne doit **pas** pouvoir faire, et ce qu'un utilisateur connecté ne doit pas pouvoir faire sur les données d'un autre |
| Système | `test/system` | un vrai parcours dans un navigateur piloté | deux ou trois parcours critiques, surtout avec du JavaScript — pas une page sur deux. Le parcours montré en démonstration ou livré au client est critique par définition : il a son test système avant la démo |

`bin/rails test` ne lance pas les tests système ; `bin/rails test:all` ou `test:system` les inclut. Depuis Rails 8.1, le générateur n'en crée plus par défaut, et une application neuve n'a même plus `test/system/` ni `test/application_system_test_case.rb` : le premier `bin/rails generate system_test <nom>` les crée. C'est voulu, on les réserve à l'essentiel.

**Le test d'accès croisé est obligatoire** dès qu'une donnée appartient à un compte : pour chaque ressource qui a un propriétaire, un test où un autre utilisateur connecté tente de la voir ou de la modifier, et doit être refusé. C'est la faille la plus répandue des applications web (contrôle d'accès défaillant, n°1 de l'OWASP), et aucun outil automatique ne la voit à ta place.

**Trois règles contre les tests qui ne testent rien**, parce que ce sont les pièges connus du code généré :

- **Un test doit d'abord échouer.** Avant de le déclarer bon, casse volontairement le code qu'il couvre et vérifie qu'il rougit. Un test qui ne peut pas échouer ne protège rien.
- **Ne modifie jamais un test pour le faire passer** sans la validation explicite de l'utilisateur, et dis-lui ce que tu changes et pourquoi. Si le test était juste, c'est le code qui a tort.
- **Pas d'assertion toujours vraie**, pas de test qui recopie le code testé, pas de test ignoré (`skip`) sans commentaire daté expliquant pourquoi.

### 3. Une sous-étape à la fois

Tu exécutes la sous-étape demandée, et uniquement celle-là. Tu ne fais pas la suivante « tant qu'on y est ». Tu ne touches pas à un fichier absent de la recette.

Si tu découvres en cours de route quelque chose que la recette ne prévoyait pas — une gem manquante, une dépendance oubliée, un choix à trancher — tu t'arrêtes et tu le signales. Tu proposes une sous-étape préalable ou une correction de la recette. Tu n'improvises pas.

### 4. L'ordre d'écriture

À l'intérieur d'une sous-étape, écris dans l'ordre où le code s'exécute : la route, puis le contrôleur, puis le modèle si besoin, puis la vue. Jamais la vue en premier.

Cet ordre n'est pas esthétique. Une vue écrite avant son contrôleur appelle des méthodes et des variables qui n'existent pas encore : elle ne peut pas être vérifiée, et l'erreur n'apparaît qu'à la fin, quand tout est déjà écrit. En suivant le flux d'exécution, chaque morceau est vérifiable dès qu'il est posé.

Une seule chose à la fois. Ne commence pas un second fichier avant que le premier fonctionne.

**Recharge le navigateur souvent**, après chaque morceau qui peut être vu, pas seulement à la fin de la sous-étape. Cinq changements empilés produisent une erreur qu'on ne sait plus attribuer.

**Lis les erreurs.** Le message dit ce qui s'est passé, les journaux du serveur (`log/development.log`) disent où. Ne propose pas un correctif plausible avant d'avoir lu les deux : un correctif qui tombe juste par hasard masque la vraie cause et la fait réapparaître plus tard.

### 5. La fin de sous-étape

Quand la sous-étape est écrite, tu produis dans cet ordre :

1. le résumé de ce qui a été fait, fichier par fichier, une ligne chacun ;
2. le résultat des contrôles (`bin/controles`, skill `rails-controles`) et de la suite de tests, lancés par toi, sortie exacte à l'appui ;
3. ce que l'utilisateur doit vérifier lui-même : commandes ou URL, et ce qu'il doit voir ;
4. ce qu'il doit relire en priorité, et la notion Rails que chaque fichier met en œuvre ;
5. la commande de commit du code, avec son message ;
6. **après ce commit**, le lancement de `bin/recette N.M "description"` : c'est lui qui écrit le résultat dans le journal, pas toi, et il doit pointer vers le commit du code testé, d'où l'ordre. Le journal fait ensuite l'objet d'un second commit (« Journal : recette N.M ») ;
7. la case cochée dans la recette.

Tu t'arrêtes là. Tu ne passes pas à la suivante avant que l'utilisateur ait vérifié et commité.

### 6. La reprise de session

Chaque session commence par la lecture de trois fichiers : `CLAUDE.md`, la recette de l'étape en cours, et `docs/a-faire-plus-tard.md`. La phrase de reprise standard est « Reprends à la première case non cochée ».

Ne redemande pas ce qui est écrit dans ces fichiers. Si une décision a été prise, elle y est. Si elle n'y est pas, elle n'a pas été prise.

## En équipe

La méthode ne change pas à plusieurs ; ce qui change, c'est où elle vit et qui relit.

- **La méthode voyage avec le dépôt.** Les skills sont copiés dans `.claude/skills/` du projet (Claude Code les lit comme les skills personnels), le `CLAUDE.md` porte les décisions, `bin/controles` et `bin/recette` sont versionnés. Une règle qui n'est que dans la tête ou le compte d'une personne n'existe pas pour les autres. Un membre qui n'utilise pas l'IA suit la même recette et le même format : la méthode ne dépend pas de l'outil.
- **Une story = une issue = une branche = une pull request.** La recette de la story vit dans `docs/recettes/<numéro-issue>-<slug>.md` et l'issue y renvoie ; ses cases sont les sous-étapes. Personne ne commence une story sans se l'être assignée.
- **Le format de fin de sous-étape devient le corps de la PR** (fichiers, contrôles, tests, à vérifier, à relire en priorité) : le relecteur sait quoi regarder avant d'ouvrir le diff.
- **Relecture croisée.** L'auteur n'approuve pas sa propre PR, l'IA non plus. Le relecteur applique la règle du skill : s'il ne peut pas expliquer un bloc, il demande au lieu d'approuver. `main` est protégée : pas de push direct, une PR verte et une approbation.
- **Un seul point de contrôle.** `bin/ci` (ou les mêmes commandes dans le workflow distant, même ordre) tourne sur chaque PR. Ce qui bloque en local bloque à distance, et rien d'autre.
- **Le journal est écrit depuis plusieurs branches.** `docs/journal/recettes.jsonl` est en ajout seul, donc Git doit concaténer au lieu de signaler un conflit : `.gitattributes` avec `docs/journal/recettes.jsonl merge=union` (c'est dans l'installation du skill `rails-controles`).
- **Les conflits de styles se préviennent par la structure.** Un fichier de composant par partial ; seul le fichier d'index (`application.scss` ou équivalent) est touché par tout le monde, et un conflit s'y résout en une ligne.

## Règles d'or du code

- **Écris du Rails ennuyeux.** Pas de métaprogrammation, pas d'astuce, pas de gem exotique. Si une solution est plus courte mais moins évidente, prends la plus évidente. En cas d'hésitation, prends celle qui figure dans les guides officiels de Rails : c'est elle que le prochain développeur reconnaîtra.
- **KISS** : la solution la plus simple qui fonctionne. Pas d'abstraction avant le troisième usage. Un partial de 30 lignes lisible vaut mieux qu'un partial « générique » de 120 lignes rempli de conditions.
- **DRY, au sens exact** (« Don't Repeat Yourself », une information vit à un seul endroit : une couleur dans le fichier de variables, une durée dans la configuration, une règle métier dans le modèle). Quand une règle existe déjà, on l'appelle ; quand elle doit changer, on la change à son seul endroit et on vérifie tous ses appels, au lieu d'en écrire une seconde version à côté. Deux bouts de code qui se ressemblent ne portent pas forcément la même information : ne les fusionne pas par réflexe, une duplication coûte moins qu'une mauvaise abstraction.
- **SOLID, appliqué à Rails** :
  - *Responsabilité unique* : un partial affiche, il ne va pas chercher les données. Un contrôleur orchestre : il trouve, délègue, rend. La règle métier vit dans le modèle, ou dans un objet dédié quand le modèle grossit.
  - *Ouvert/fermé* : on étend un partial par ses `locals` et par `yield` / `content_for`, pas en ajoutant un `if` à chaque nouveau cas.
  - *Substitution* : deux partials qui rendent le même type de contenu reçoivent les mêmes locals (un objet `record:`, pas dix locals éclatés).
  - *Ségrégation des interfaces* : locals minimaux, pas de local « au cas où ».
  - *Inversion des dépendances* : le contrôleur charge les données, avec `includes` quand une liste sera parcourue, et les passe à la vue. Aucune requête dans une vue ou un partial. Un partial reçoit des locals, jamais une variable d'instance `@…`.
- **Pas de gem sans demander d'abord**, en expliquant ce qu'elle apporte qu'on ne peut pas écrire en dix lignes. Toute gem ajoutée : la raison dans le message de commit, `Gemfile` et `Gemfile.lock` dans le même commit.

## Conventions Rails à respecter

Ce sont les conventions des guides officiels et de la configuration par défaut d'une application neuve. Le `CLAUDE.md` du projet peut les préciser ; il ne devrait pas les contredire sans une note de décision.

### Côté serveur

- Nommage Rails strict : modèle au singulier, table au pluriel, contrôleur au pluriel, les sept actions CRUD (`index show new create edit update destroy`) et rien d'autre dans un contrôleur de ressource. Un besoin qui ne rentre pas dans les sept actions est d'abord une nouvelle ressource (`resources :acceptances, only: :create`). Une route `member` (`patch :accept, on: :member`) est admise quand le `CLAUDE.md` l'a décidée et nommée : elle est alors déclarée dans `routes.rb` avec `only:`/`member`, son action porte le marqueur `controles: ok route member, <décision>`, et elle reste un changement d'état en une ligne qui délègue au modèle (`@order.accept!`).
- Classes, méthodes, variables, colonnes en anglais. Les textes visibles passent par les fichiers de traduction (`config/locales/`) et `t()`, jamais en dur dans une vue, un modèle ou un contrôleur — c'est la convention Rails, et le `CLAUDE.md` dit si le projet la suit dès le départ (recommandé : un texte qu'on retrouve par sa clé se relit et se corrige sans toucher au code).
- Paramètres autorisés : `params.expect(model: [...])` à partir de Rails 8.0, `params.require(...).permit(...)` avant. **Un jeu de paramètres par rôle** : ce qu'un visiteur anonyme peut envoyer et ce qu'un administrateur peut modifier ne partagent jamais la même liste, même pour le même modèle. Un champ réservé est absent du formulaire du rôle qui n'y a pas droit, pas masqué en CSS.
- **Autorisation explicite** dès qu'une application a plusieurs rôles ou que des données appartiennent à un compte : chaque action d'un contrôleur de ressource dit qui a le droit. Avec Pundit (la convention la plus répandue) : `authorize` dans l'action, `policy_scope` sur les listes, et `verify_authorized` / `verify_policy_scoped` en `after_action` dans `ApplicationController`, pour qu'un oubli fasse une erreur à l'écran plutôt qu'une faille en production. Être connecté (Devise, `authenticate_user!`) n'est pas être autorisé.
- Toute méthode qui n'est pas une action est sous `private`. Une méthode utilitaire hors de `private` devient une action accessible par URL.
- Validations dans le modèle, contraintes correspondantes en base (`null: false`, index unique) : la validation protège le formulaire, la contrainte protège la base.
- Migrations : on ajoute, on ne supprime pas dans la même version. Retirer une colonne se fait en deux temps (`ignored_columns` d'abord, suppression plus tard), parce qu'un déploiement en cours lit encore l'ancienne structure.
- **Données de démonstration** : `db/seeds.rb` est du code, idempotent (`find_or_create_by!`), relançable par `db:seed:replant`, sans aucune donnée réelle. Toute table créée dans une sous-étape reçoit ses seeds dans la même sous-étape si la donnée s'affiche quelque part ; une démo qui repose sur des données saisies à la main la veille n'est pas reproductible.
- Dates et heures : `Time.current`, fuseau configuré dans `application.rb`, jamais `Time.now` ni l'heure du navigateur.
- Jetons et identifiants exposés dans une URL : `has_secure_token` ou `generates_token_for`, jamais un identifiant séquentiel.
- Sécurité par défaut, à ne jamais désactiver sans commentaire justificatif : échappement automatique des vues (`html_safe` et `raw` sont des exceptions documentées), protection CSRF, `filter_parameters` tenu à jour pour tout champ personnel, aucun secret dans le dépôt (`credentials` ou variables d'environnement).
- Style : `rubocop-rails-omakase` tel quel, sans règle ajoutée. Si un template impose son propre `.rubocop.yml`, le `CLAUDE.md` dit lequel fait foi et pourquoi ; on n'en garde qu'un. Analyse : `brakeman` et `bundler-audit`. Dans une application neuve, `rubocop-rails-omakase` et `brakeman` sont présents depuis Rails 7.2, `bundler-audit` et `bin/ci` depuis 8.1 ; sur un projet plus ancien, les ajouter est une sous-étape dédiée, à faire valider comme toute gem.

### Ce qui marche avec 40 lignes et casse avec 10 000

Ces erreurs ne se voient ni en développement ni en démo, parce que la base y est petite. Elles se voient en production, et c'est le code généré qui les fait le plus souvent, parce qu'il écrit ce qui est le plus court.

- **Une liste chargée entière.** `Model.all` parcouru dans une vue charge toute la table en mémoire. Toute liste affichée a une borne : une pagination (`limit`/`offset`, ou une gem décidée dans le `CLAUDE.md`), ou un `limit` explicite quand on n'affiche que les premiers. Un traitement sur toute une table passe par `find_each` / `in_batches`, jamais `all.each`.
- **La requête dans la boucle (N+1).** Une liste de 50 commandes qui affiche `order.company.name` fait 51 requêtes. Toute association lue dans une boucle est chargée avec `includes` dans le contrôleur. En développement, la gem `bullet` le signale ; son ajout est une décision à valider.
- **Le calcul en Ruby de ce que la base sait faire.** `orders.map(&:total).sum` charge tout ; `orders.sum(:total_cents)` fait une requête. Comptes, sommes, existence : `count`, `sum`, `exists?`, pas `length`, `map`, `any?` sur une relation chargée.
- **La colonne cherchée sans index.** Toute clé étrangère (`t.references` le fait seul), toute colonne de `where` fréquent, toute colonne d'unicité (index unique, qui est aussi la vraie garantie de la validation `uniqueness`) a son index dans la migration qui la crée.
- **La valeur lue puis réécrite.** Un stock décrémenté par `stock = stock - qty` lu puis sauvé laisse deux commandes simultanées passer sur la même unité. Un changement qui dépend de la valeur courante se fait dans une transaction avec verrou (`with_lock`) ou en une seule instruction SQL (`update_all("stock = stock - ?", qty)` sous condition `stock >= ?`), et un test le prouve.
- **L'identifiant qui vient de l'URL mis tel quel dans une requête.** `where("name = '#{params[:q]}'")` est une injection SQL. Toute valeur extérieure passe par les paramètres de requête (`where(name: params[:q])`, `where("name ILIKE ?", "%#{q}%")` avec `sanitize_sql_like`), et un tri par colonne demandée par l'URL passe par une liste blanche, jamais `order(params[:sort])`.
- **Le travail lent dans la requête web.** Un e-mail, un PDF, un appel externe se font dans une tâche de fond (`deliver_later`, Active Job) ; la réponse à l'utilisateur n'attend pas un service tiers.
- **Le formulaire ouvert sans limite.** Toute action qui crée, envoie ou coûte (inscription, connexion, envoi d'e-mail, commande) porte une limitation de débit : `rate_limit to:, within:` dans le contrôleur à partir de Rails 8.0, et Devise bloque déjà les tentatives de connexion si `lockable` est activé.

### Ce qui marche aujourd'hui et casse un jour

Le code qui « fonctionne » à la démo mais qu'un développeur confirmé refuserait, parce qu'il a vu ce que ça donne six mois plus tard.

- **L'erreur avalée.** `rescue => e` suivi de rien, `rescue nil`, `rescue Exception` : le programme continue comme si de rien n'était et l'erreur réapparaît ailleurs, sans trace. On ne rattrape qu'une exception précise, qu'on sait traiter, et on la journalise ; sinon on la laisse remonter, c'est le rôle de Rails de l'afficher et de la consigner.
- **Le raccourci qui saute les validations.** `update_attribute`, `update_column`, `save(validate: false)`, `skip_callbacks` : la règle écrite dans le modèle n'est plus appliquée, et la base reçoit ce que le formulaire aurait refusé. Ils sont interdits sauf justification écrite sur la ligne (`controles: ok …`).
- **Le `nil` qu'on n'attendait pas.** `find_by` renvoie `nil` quand rien ne correspond, `find` lève une erreur. Dans une action de contrôleur, `find` (via le propriétaire) donne une 404 propre ; `find_by` n'est utilisé que si le cas « absent » est traité sur la ligne suivante.
- **L'association sans `dependent`.** Un `has_many` sans `dependent: :destroy` (ou `:restrict_with_error`, selon la règle métier) laisse des lignes orphelines à chaque suppression. Chaque `has_many` dit ce qui arrive aux enfants, et la clé étrangère en base porte la même règle (`on_delete`).
- **Le callback qui fait trop.** Un `after_save` qui envoie un e-mail, appelle un service, crée d'autres enregistrements : invisible depuis le contrôleur, impossible à désactiver dans un test, déclenché par un `save` qu'on ne soupçonnait pas. Un effet de bord se déclenche depuis le contrôleur ou une méthode métier nommée (`order.accept!`), jamais depuis un callback ; les callbacks se limitent à préparer l'enregistrement lui-même (normaliser, calculer un champ).
- **La constante magique.** `30`, `0.2`, `"pending"` écrits en plein code. Une valeur métier vit dans une constante nommée ou un `enum` (`status`), une durée ou un seuil dans la configuration, et leur sens est dans le nom.
- **La migration qu'on ne peut pas défaire.** `change` avec une opération non réversible, ou des données modifiées dans une migration de structure. Toute migration se joue et se rejoue (`db:rollback` puis `db:migrate` dans la recette), et une migration de données est un script à part.
- **Le code mort et le `TODO` sans date.** Une méthode plus appelée, une vue plus routée, un `TODO` sans qui ni quand : chacun est retiré ou transformé en entrée de `docs/a-faire-plus-tard.md`.

### Côté navigateur

- Une vue = une page. Tout bloc répété devient un partial, appelé avec des locals.
- HTML sémantique : un seul `<h1>`, hiérarchie de titres continue, `<header> <nav> <main> <section> <article> <footer>` réels, un `<label for>` par champ, un `alt` par image (`alt=""` si décorative), `<button>` pour agir et `<a>` pour naviguer, jamais un `<div>` cliquable.
- Accessibilité minimale non négociable : contraste 4,5:1, focus clavier visible, toute action possible au clavier, erreurs de formulaire liées au champ par `aria-describedby` et jamais signalées par la couleur seule, respect de `prefers-reduced-motion`.
- Pas de balise `<style>`, pas d'attribut `style=""` (sauf dans les vues de mailers, où les clients mail l'imposent), pas de JavaScript inline.
- Avec Hotwire (le défaut de Rails ; sinon le `CLAUDE.md` dit quoi) : tout comportement passe par un contrôleur Stimulus — un contrôleur = un comportement = un fichier, trente lignes de code maximum, un commentaire en tête disant ce qu'il fait et sur quelle page — et les mises à jour partielles passent par Turbo Frames et Streams, pas par un `fetch` écrit à la main.
- CSS, quelle que soit la stack (Sass, Bootstrap, Tailwind, CSS pur — voir `rails-controles` pour les contrôles propres à chacune) : aucune couleur, taille ou espacement en dur hors du fichier de variables ou de thème ; un framework CSS se personnalise par ses variables, jamais en recopiant ses sélecteurs ; pas d'identifiant comme accroche de style ; pas de `!important` ; **mobile d'abord**, les media queries montent en largeur.
- Quand le projet écrit ses classes (Sass, CSS pur) : nommage BEM (`.block__element--modifier`), deux niveaux d'imbrication maximum, un style qui revient = un fichier de composant. Sous Bootstrap : la charte passe par les variables Sass redéfinies avant `@import "bootstrap"` (`$primary`, `$font-family-base`, `$border-radius`…), jamais en réécrivant `.btn` ou `.navbar` dans un fichier de composant ; les classes utilitaires dans les vues sont normales, mais un bloc d'interface qui revient devient un partial. Sous Tailwind : pas de valeur arbitraire (`bg-[#…]`) hors du thème, et un bloc d'interface qui revient devient un partial plutôt qu'une liste de classes recopiée — c'est ce que recommande la documentation de Tailwind elle-même, de préférence à `@apply`.
- Chaque page porte son `<title>` et sa meta description, définis dans la vue (`content_for`), pas dans le gabarit.

## Annotation du code

Objectif : qu'une personne extérieure comprenne le fichier sans poser de question.

- Un commentaire en tête de chaque fichier non trivial : à quoi il sert, en une phrase.
- Un bloc de pseudo-code en commentaire au-dessus de toute méthode dont la logique dépasse cinq lignes, décrivant les étapes dans la langue du projet avant le code.
- Un commentaire au-dessus de toute portion non évidente, qui explique le **pourquoi**, jamais le quoi. `# incrémente le compteur` n'apporte rien ; `# on ne compte que les commandes payées : une commande abandonnée au panier ne doit pas entrer dans le chiffre affiché` apporte la règle.
- Chaque migration porte un commentaire expliquant la décision métier qu'elle traduit.
- Toute décision non évidente est signalée par `# CHOIX :` suivi de la raison, pour qu'on la retrouve par `grep`.

## Ce qui n'est jamais acceptable

Ces règles ne sont pas des préférences, ce sont des sources d'erreur constatées.

**Une valeur écrite à deux endroits.** Couleur, texte visible, durée, nom du projet, adresse : chaque valeur existe à un seul endroit. Écrire `#FF6600` dans un style ou un nom de site dans une vue, c'est une dette que quelqu'un paiera en cherchant dans cinquante fichiers le jour où ça change.

**Une donnée fictive présentée comme vraie.** Un compteur à 1 500 sans rien en base derrière, une date non confirmée, un nom provisoire sans le dire. Marque `[À ÉCRIRE]` ou retire le bloc. Dans une maquette, un bandeau visible dit que les données sont fictives.

**Un travail hors du périmètre annoncé.** Si la recette dit trois fichiers et que tu en touches un quatrième parce que c'était plus propre, tu as rompu le contrat. L'utilisateur ne sait plus ce qui a été décidé et ce qui a été improvisé.

**Une méthode qui existe déjà, réécrite autrement.** Avant d'écrire une méthode qui formate, calcule ou affiche, cherche si elle existe : `grep -rn "def " app/models/ app/helpers/`. Si une méthode proche existe, utilise-la ou étends-la. Deux méthodes qui font la même chose différemment produisent des bugs qui n'apparaissent que parfois.

**Une décision qui ne vit que dans la conversation.** Ce qui a été tranché va dans `docs/a-faire-plus-tard.md` ou `docs/decisions/` (contexte, options, critères, choix, raisons). Une décision absente des fichiers n'existe pas à la session suivante.

**Un résultat de test annoncé sans avoir été lancé.** « Les tests passent » n'est vrai que si la commande a tourné et que son code de sortie est zéro. Avec `bin/recette`, c'est le script qui l'écrit ; sans lui, colle la sortie exacte de la commande.

**Une technologie hors de la liste du `CLAUDE.md`.** Une gem, une bibliothèque JavaScript, un service externe, une police chargée depuis un domaine tiers : chacun est une décision, pas une commodité.

## Ce que tu signales sans qu'on te le demande

Tu es le binôme de relecture, pas un exécutant. Ces situations appellent un signalement avant d'agir :

- une gem prévue dans le `CLAUDE.md` qui n'est pas installée, ou une version qui ne correspond pas à `Gemfile.lock` ;
- une méthode qui refait un parcours complet à chaque appel dans une boucle, une liste parcourue sans `includes`, une liste affichée sans borne, une valeur extérieure interpolée dans une requête ;
- une action de contrôleur qui lit ou modifie une donnée appartenant à un compte sans `authorize` ni `policy_scope`, ou un `find` sur une ressource possédée qui ne passe pas par le propriétaire (`current_user.orders.find` plutôt que `Order.find`) ;
- un formulaire public sans protection anti-robot ni limitation de débit ;
- une durée, un chiffre, une date affichés sans avoir été arbitrés ;
- un texte visible écrit dans une vue plutôt que dans le fichier de traduction ;
- un champ de formulaire ou une donnée collectée dont l'usage n'est pas justifié par le `CLAUDE.md` ;
- un choix qui dégrade la sécurité ou la protection des données personnelles, même demandé ;
- une consigne du `CLAUDE.md` qui te semble contre-productive, ou une demande qui le contredit : dis-le avant d'exécuter, au lieu de contourner en silence.

Tu signales, tu proposes, tu attends la réponse. Tu n'appliques pas ta proposition toi-même.

## Le régime allégé

Quand une erreur se verrait immédiatement à l'écran — pages de contenu, textes, mise en page — l'utilisateur peut demander un régime allégé : tu exécutes la sous-étape entière sans t'arrêter entre les fichiers, et tu produis la vérification à la fin.

Ce régime ne s'applique jamais à ce qui touche la base de données, les formulaires, les e-mails, l'authentification, l'autorisation, le cache ou la sécurité. Là, une erreur ne se voit pas et se paie plus tard.

**Allégé quand une erreur se voit, strict quand elle ne se voit pas.**

## Git

- Une sous-étape validée = un commit du code, puis un commit du journal. Message à l'impératif, une ligne, dans la langue du projet : « Ajoute le formulaire de contact ».
- Par défaut, une étape (en équipe : une story) = une branche `feat/…` ou `fix/…` fusionnée par pull request ; le `CLAUDE.md` peut simplifier pour un projet à une seule personne.
- Toute gem ajoutée : `Gemfile` et `Gemfile.lock` dans le même commit, la raison dans le message.
- Le journal `docs/journal/` (ligne JSON par recette et sorties brutes) est versionné avec le code : c'est l'historique Git qui garantit qu'aucune ligne n'a été retouchée.

## Format de fin de sous-étape

Utilise ce gabarit, dans la langue du projet, sans le décorer. En équipe, c'est aussi le corps de la pull request.

```
Sous-étape N.M terminée.

Fichiers :
- chemin/fichier — ce qui a été fait, une ligne

Contrôles : bin/controles [tous vides / ce qui remonte et pourquoi]
Tests : [commande exacte] → [dernière ligne de la sortie, telle quelle]
Journal (après le commit) : bin/recette N.M "description" → [vert / rouge]

À vérifier :
- commande ou URL → ce que tu dois voir

À relire en priorité :
- chemin/fichier → notion Rails employée → guide officiel (lien)

Commit proposé :
git add [fichiers]
git commit -m "[message selon la convention du projet]"

Je m'arrête là.
```

## Gabarit de recette

Fichier `docs/recettes/etape-N.md` (en équipe : `docs/recettes/<numéro-issue>-<slug>.md`, lié depuis l'issue) :

```markdown
# Étape N — [titre]

Objectif : [deux phrases]

## Sous-étapes

- [ ] N.1 — [titre]
  - Fichiers : chemin/un, chemin/deux
  - Technologie : [ce qui est employé, et pourquoi si ce n'est pas évident]
  - Tests : test/models/…_test.rb — [les phrases « quand je fais ça, j'attends ça »]
  - Vérification : [commande ou URL → ce qu'on doit voir]
  - Estimation : ~N lignes

- [ ] N.2 — …

## Points ouverts

- [question] → option retenue : [laquelle], parce que [raison]
```
