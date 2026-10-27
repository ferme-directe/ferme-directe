# Ferme Directe

Place de marché entre des fermes et des acheteurs professionnels. Projet final Le Wagon, batch 2312.

## Démarrer

```
git clone git@github.com:ferme-directe/ferme-directe.git
cd ferme-directe
bundle install
bin/rails db:create db:migrate db:seed
bin/rails test
bin/rails server
```

Puis http://localhost:3000, compte `acheteur@ferme-directe.test`, mot de passe `motdepasse`.

## Travailler sur une story

Une story = une issue = une branche = une PR. Tout est dans [`CLAUDE.md`](CLAUDE.md) : stack, conventions,
modèle de données, méthode. Avant d'ouvrir une PR : `bin/ci`.

Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates).
