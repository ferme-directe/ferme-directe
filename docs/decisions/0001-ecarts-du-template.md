# 0001 · Écarts du template Le Wagon et décisions prises

Date : 27 octobre 2026 · Statut : acceptée

## Contexte

L'application est générée avec `rails new -d postgresql -m …/lewagon/rails-templates/master/devise.rb`.
Le template change plusieurs défauts d'une application Rails 8.1 neuve. Chaque écart est noté ici une fois,
pour que personne ne le redécouvre à ses frais.

## Écarts et décisions

| Écart du template | Décision | Pourquoi |
|---|---|---|
| Fixtures désactivées (`generate.test_framework :test_unit, fixture: false`) | **Rétablies** | Minitest lit ses données de test dans les fixtures ; sans elles, chaque test crée ses données à la main. |
| Workflow de CI `.github/workflows/ci.yml` supprimé | **Rétabli**, il lance `bin/ci` | La CI vérifie chaque PR sans dépendre de la machine ni de l'IA de personne. |
| `.rubocop.yml` du Wagon à la place de `rubocop-rails-omakase` | **On garde celui du Wagon** | C'est celui du cours ; un seul fait foi. |
| Sprockets + sassc à la place de Propshaft | On garde | Bootstrap et les feuilles du Wagon en dépendent. |
| Vues Devise générées en anglais (Simple Form, Bootstrap) | Gardées ; messages et erreurs traduits par `devise-i18n` ; vues exclues du contrôle `t()` de `bin/controles` | La démo passe par des comptes de seeds. Traduire les vues est noté dans `docs/a-faire-plus-tard.md`. |
| Kamal, `Dockerfile`, `config/deploy.yml` générés par Rails | Non utilisés | On déploie sur Scalingo. Fichiers gardés, inoffensifs. |
| Dependabot hebdomadaire, 10 PR ouvertes au plus | Mensuel, mises à jour mineures groupées | Éviter une PR par gem chaque semaine pendant le projet. |
| Fuseau horaire UTC | `config.time_zone = "Paris"` | Les heures des commandes et du bon de commande. |
