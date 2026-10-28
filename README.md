# Ferme Directe

Place de marché entre des fermes et des acheteurs professionnels. Projet final Le Wagon, batch 2312.

## Démarrer

```
git clone git@github.com:ferme-directe/ferme-directe.git
cd ferme-directe
bundle install
bin/rails db:create db:migrate db:seed
bin/rails test                       # 23 tests, tous verts
bin/dev                              # le serveur + la compilation du CSS (pas `rails s`)
```

Puis http://localhost:3000, compte `acheteur@ferme-directe.test`, mot de passe `motdepasse`.

## Travailler sur une story

Une story = une issue = une branche = une PR. Tout est dans [`CLAUDE.md`](CLAUDE.md) : stack, conventions,
modèle de données, méthode. Avant d'ouvrir une PR : `bin/ci`.

Application née du template [lewagon/rails-templates](https://github.com/lewagon/rails-templates) (`devise.rb`).
Ce qu'on en a gardé, retiré ou remplacé, et pourquoi : [`docs/decisions/0001-ecarts-du-template.md`](docs/decisions/0001-ecarts-du-template.md).
