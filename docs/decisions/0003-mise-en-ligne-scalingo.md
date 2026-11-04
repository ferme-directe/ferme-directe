# 0003 · Mise en ligne sur Scalingo : une seule base de données

Date : 31 octobre 2026 · Statut : acceptée

## Contexte

L'application est hébergée sur Scalingo (décision 12 du cadrage), région osc-fr1 (Paris), app `ferme-directe`,
déployée automatiquement à chaque fusion sur `main`. Un conteneur web M et un addon PostgreSQL Starter 512M.

Rails 8 configure quatre bases en production : `primary` (les tables de l'application), `queue` (Solid Queue,
les tâches de fond : nos e-mails), `cache` (Solid Cache) et `cable` (Solid Cable). L'addon PostgreSQL de Scalingo
fournit une seule base, par la variable `DATABASE_URL`. Or Rails ne lit `DATABASE_URL` que pour `primary`
(`activerecord/lib/active_record/database_configurations.rb`, `environment_value_for`). Les trois autres
auraient cherché `ferme_directe_production_queue` sur `localhost` : `bin/rails db:migrate` aurait échoué,
et Scalingo annule un déploiement dont le hook `postdeploy` échoue.

## Décision

**Une seule base pour tout.** C'est la marche à suivre du README de Solid Queue (« single database ») et de la
documentation Scalingo sur Solid Queue.

- `config/database.yml` : en production, une seule entrée, lue depuis `DATABASE_URL`.
- Les tables de Solid Queue, Solid Cache et Solid Cable : une migration (`20261031140000_create_solid_tables`),
  recopiée de `db/queue_schema.rb`, `db/cache_schema.rb` et `db/cable_schema.rb`, supprimés. Elles entrent dans
  `db/schema.rb` comme toutes les autres.
- `config/environments/production.rb` : plus de `config.solid_queue.connects_to` ; `config/cache.yml` : plus de
  `database: cache` ; `config/cable.yml` : plus de `connects_to`.
- `Procfile` : `web: bundle exec puma -C config/puma.rb` et `postdeploy: bin/rails db:migrate`.
- Les tâches de fond tournent **dans le conteneur web** : `SOLID_QUEUE_IN_PUMA=1` dans l'environnement Scalingo
  active `plugin :solid_queue` dans `config/puma.rb`. Pas de second conteneur (14,40 € HT/mois de plus) pour
  une démo.
- Variables d'environnement posées sur Scalingo, jamais dans le dépôt : `RAILS_MASTER_KEY`, `SEED_PASSWORD`,
  `SOLID_QUEUE_IN_PUMA`. `DATABASE_URL` est posée par l'addon. La liste, sans valeur, est dans `.env.example`.
- L'hôte des liens dans les e-mails : `ferme-directe.osc-fr1.scalingo.io`, à remplacer par le domaine Infomaniak
  quand il sera branché (`docs/a-faire-plus-tard.md`).

## Conséquences

- Les seeds en production : `scalingo --app ferme-directe run bin/rails db:seed`, une fois, avec la CLI Scalingo.
- Une base de 512 Mo et 30 connexions pour tout : largement assez pour une démo. Si un jour l'application grossit,
  Rails sait remettre Solid Queue dans une base à part ; c'est une migration, pas une réécriture.
- Les « review apps » de Scalingo (une app par PR) restent désactivées : chacune serait facturée.

## Rejeté

- **Quatre bases Scalingo** : quatre addons facturés, pour séparer ce qu'une démo ne sépare pas.
- **`queue_adapter = :async`** en production (les e-mails partent dans un fil du serveur, perdus s'il redémarre) :
  la ligne de moins ne vaut pas de renoncer à l'outil que Rails 8 installe et que le cadrage nomme.
