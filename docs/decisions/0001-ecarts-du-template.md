# 0001 · Écarts du template Le Wagon et décisions prises

Date : 27 octobre 2026 · Statut : acceptée

## Contexte

L'application est générée avec `rails new -d postgresql -m …/lewagon/rails-templates/master/devise.rb`.
Le template change plusieurs défauts d'une application Rails 8.1 neuve. Chaque écart est noté ici une fois,
pour que personne ne le redécouvre à ses frais.

Le template a été utilisé sans décision formelle de l'équipe : la commande figurait dans le script de lancement.
On le garde pour ses outils (Devise, Bootstrap, Simple Form) ; son visuel (barre, logo, styles d'exemple) est remplacé par le nôtre.

## Écarts et décisions

| Écart du template | Décision | Pourquoi |
|---|---|---|
| Fixtures désactivées (`generate.test_framework :test_unit, fixture: false`) | **Rétablies** | Minitest lit ses données de test dans les fixtures ; sans elles, chaque test crée ses données à la main. |
| Workflow de CI `.github/workflows/ci.yml` supprimé | **Rétabli**, il lance `bin/ci` | La CI vérifie chaque PR sans dépendre de la machine ni de l'IA de personne. |
| `.rubocop.yml` du Wagon à la place de `rubocop-rails-omakase` | **On garde celui du Wagon** | C'est celui du cours ; un seul fait foi. |
| Sprockets + sassc à la place de Propshaft | **Remplacés** le 28 oct. par Propshaft + Dart Sass (`dartsass-rails`) | Propshaft est le défaut de Rails 8 ; LibSass, le moteur de `sassc`, est en fin de vie (équipe Sass, 23 oct. 2025) ; la gem `bootstrap` recommande `dartsass-rails` avec Propshaft. Fait avant la première ligne de CSS, quand changer ne coûte presque rien. On lance `bin/dev`. |
| Vues Devise générées en anglais (Simple Form, Bootstrap) | Gardées ; messages et erreurs traduits par `devise-i18n` ; vues exclues du contrôle `t()` de `bin/controles` | La démo passe par des comptes de seeds. Traduire les vues est noté dans `docs/a-faire-plus-tard.md`. |
| Kamal (`.kamal/`, `config/deploy.yml`, `bin/kamal`, gem `kamal`), générés par Rails | **Supprimés** le 28 oct. | Outil de déploiement sur son propre serveur ; on déploie sur Scalingo. Des fichiers qui ne déploient rien égarent le lecteur. |
| `Dockerfile`, `thruster` | Gardés | Standards de Rails, sans effet avec Scalingo, réutilisables si on change d'hébergement. |
| Vues Devise des modules non activés (`confirmations`, `unlocks` et leurs e-mails) | **Supprimées** le 28 oct. | `User` n'active ni la confirmation par e-mail ni le verrouillage : ces vues ne s'affichent jamais. |
| Barre de navigation du Wagon (`shared/_navbar.html.erb`, logo et avatar chargés depuis les serveurs du Wagon) | **À remplacer** par la nôtre, selon notre charte | Un exemple du template, pas notre identité. Voir `docs/a-faire-plus-tard.md`. |
| `font-awesome-sass` (jeu d'icônes) | **Retiré** le 28 oct. | Utilisé nulle part, chargé sur chaque page, et il nous attachait à `sassc`. Une icône dont on a besoin = son SVG dans la vue. |
| `autoprefixer-rails` | **Retiré** le 28 oct. | Ajoute des préfixes CSS pour d'anciens navigateurs, inutiles aujourd'hui ; il demande JavaScript côté serveur, risque au déploiement. |
| `simple_form` tiré de la branche GitHub | **Version publiée** (`~> 5.4`) le 28 oct. | Une version publiée est stable ; une branche GitHub est du code en cours, qu'un `bundle update` peut changer. Même gem, rien ne change dans les formulaires. |
| Styles d'exemple (`_navbar`, `_avatar`, `_alert`, `pages/_home`, `LICENSE` des feuilles du Wagon) | **À remplacer** par la charte | Retirés avec la PR de charte. On garde `_form_legend_clear.scss` (corrige un vrai bug de Bootstrap 5) et le rangement `config/`, `components/`, `pages/`. |
| Page d'accueil `pages#home` (vide) | **À supprimer** avec la story 14 | Personne ne la voit : après connexion, on arrive sur `/needs/new`. Attendre la story 1, sinon la racine plante. |
| Gardés tels quels | Devise, Bootstrap 5.3, Simple Form et ses initializers, `dotenv-rails`, `shared/_flashes`, Bootstrap et Popper dans l'importmap | Utiles et à jour. |
| Dependabot hebdomadaire, 10 PR ouvertes au plus | Mensuel, mises à jour mineures groupées | Éviter une PR par gem chaque semaine pendant le projet. |
| Fuseau horaire UTC | `config.time_zone = "Paris"` | Les heures des commandes et du bon de commande. |
