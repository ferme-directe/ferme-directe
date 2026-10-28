# À faire plus tard

Ce qu'on repère en cours de story et qu'on ne traite pas tout de suite. Une ligne par point, avec la date et la story.

- 27 oct. · socle · Traduire les textes des vues Devise (`app/views/devise`) par `t()`, puis les remettre dans le contrôle de `bin/controles`.
- 28 oct. · nettoyage · Remplacer la barre de navigation du template (`app/views/shared/_navbar.html.erb`, `components/_navbar.scss`) par la nôtre, simple, selon notre charte. Plus aucune image chargée depuis les serveurs du Wagon.
- 28 oct. · nettoyage · Remplacer les couleurs et polices d'exemple (`config/_colors.scss`, `config/_fonts.scss`) par celles de notre charte.
- 28 oct. · déploiement · `config/environments/production.rb` : remplacer l'hôte des e-mails `TODO_PUT_YOUR_DOMAIN_HERE` par notre domaine.
- 28 oct. · déploiement · `config/database.yml` : en production, une seule base. Rails 8 range par défaut Solid Queue, Solid Cache et Solid Cable dans trois bases à part ; on les met dans la base principale.
