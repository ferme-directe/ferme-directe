# À faire plus tard

Ce qu'on repère en cours de story et qu'on ne traite pas tout de suite. Une ligne par point, avec la date et la story.

- 27 oct. · socle · Traduire les textes des vues Devise (`app/views/devise`) par `t()`, puis les remettre dans le contrôle de `bin/controles`.
- 28 oct. · déploiement · `config/environments/production.rb` : remplacer l'hôte des e-mails `TODO_PUT_YOUR_DOMAIN_HERE` par notre domaine.
- 28 oct. · déploiement · `config/database.yml` : en production, une seule base. Rails 8 range par défaut Solid Queue, Solid Cache et Solid Cable dans trois bases à part ; on les met dans la base principale.
- 28 oct. · charte · Icône du site : remplacer `public/icon.png` et `public/icon.svg` (icône Rails) par la nôtre ; le navigateur demande aussi `/favicon.ico`, qui n'existe pas.
- 28 oct. · charte · Barre du haut : « Annonces », « Mes commandes » et « Fermes favorites » sont grisées faute de page dans la démo ; « Mes besoins » mène au formulaire de besoin. À brancher quand ces pages existeront.
- 31 oct. · story 6 · `Order#accept!` ne lance pas encore l'e-mail du bon de commande : à ajouter avec la story 8 (`deliver_later` après la transaction).
- 31 oct. · story 6 · `Demo::AcceptancesController` n'a pas de test d'intégration : sa route n'existe que si `DEMO_MODE` est défini au démarrage. Sa règle d'accès (`demo_accept?`) est testée dans la policy.
