# À faire plus tard

Ce qu'on repère en cours de story et qu'on ne traite pas tout de suite. Une ligne par point, avec la date et la story.

- 27 oct. · socle · Traduire les textes des vues Devise (`app/views/devise`) par `t()`, puis les remettre dans le contrôle de `bin/controles`.
- 28 oct. · charte · Icône du site : remplacer `public/icon.png` et `public/icon.svg` (icône Rails) par la nôtre ; le navigateur demande aussi `/favicon.ico`, qui n'existe pas.
- 28 oct. · charte · Barre du haut : « Annonces », « Mes commandes » et « Fermes favorites » sont grisées faute de page dans la démo ; « Mes besoins » mène au formulaire de besoin. À brancher quand ces pages existeront.
- 31 oct. · déploiement · `config/environments/production.rb` : l'hôte des e-mails est l'adresse Scalingo ; le remplacer par notre domaine Infomaniak quand il sera branché. Activer alors `force_ssl` et `assume_ssl` (commentés par le template).
