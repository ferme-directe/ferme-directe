# Les recherches de la démo, et ce qu'elles doivent rendre

Les seeds (`db/seeds.rb`) placent 24 fermes fictives dans des communes réelles, de 3,8 à 45,5 km de
Sermaise (place de l'Église, adresse de livraison de l'acheteur de démo). Les distances ci-dessous sont
celles que Geocoder calcule entre les coordonnées des seeds : ce sont les chiffres attendus à l'écran.

Compte de démo : `acheteur@ferme-directe.test` (Épicerie du Moulin, Sermaise).
Ses fermes favorites (★) : Ferme des Tilleuls (3,8 km), Ferme du Coteau (7,5 km), Rucher de l'Essonne
(21,1 km), Ferme des Quatre Vents (28,7 km). Deux proches, deux loin : quand la story 3 mettra les
favorites en tête, l'encart « Vos fermes favorites » se verra, puisque deux d'entre elles seraient
sinon loin dans la liste.

Ce que la recherche fait aujourd'hui (story 2, version minimale) : même produit, dans le rayon du besoin.
Elle ne tient pas encore compte du label, du stock ni de la date ; les favorites ne sont pas encore en
tête (story 3). Les tableaux donnent donc l'ordre par distance, les ★ en plus.

## Recherche 1 · Œufs, 300 pièces, rayon 30 km — la recherche de la démo

7 fermes, dont 3 favorites.

| km | Ferme | Commune | Prix | Dispo | Label |
|---|---|---|---|---|---|
| 3,8 ★ | Ferme des Tilleuls | Saint-Chéron | 0,36 € | 1 200 | Plein air |
| 5,4 | Les Poules de l'Orge | Dourdan | 0,42 € | 800 | Bio |
| 7,5 ★ | Ferme du Coteau | Breuillet | 0,38 € | 600 | Label Rouge |
| 12,4 | Ferme des Grands Champs | Étampes | 0,33 € | 2 000 | Plein air |
| 18,3 | La Ferme d'Ablis | Ablis | 0,31 € | 1 500 | Plein air |
| 19,5 | Ferme de la Vallée de Chevreuse | Chevreuse | 0,37 € | 700 | Plein air |
| 28,7 ★ | Ferme des Quatre Vents | Gallardon | 0,34 € | 1 800 | Plein air |

Pour 300 œufs, toutes couvrent la quantité. Total chez les Tilleuls : 108 € (le chiffre de la maquette).

## Recherche 2 · Pommes de terre, 50 kg, rayon 30 km

4 fermes, dont 2 favorites.

| km | Ferme | Commune | Prix | Dispo | Label |
|---|---|---|---|---|---|
| 7,5 ★ | Ferme du Coteau | Breuillet | 1,20 € | 900 | — |
| 11,0 | Le Potager d'Auvers | Auvers-Saint-Georges | 1,15 € | 1 500 | Bio |
| 22,4 | Ferme de la Forêt | Rambouillet | 1,05 € | 1 200 | — |
| 28,7 ★ | Ferme des Quatre Vents | Gallardon | 1,10 € | 2 000 | — |

## Recherche 3 · Miel, 5 kg, rayon 30 km

3 fermes, dont 2 favorites. Les deux premiers sont des apiculteurs ; les Quatre Vents ont des ruches
à côté de la polyculture.

| km | Ferme | Commune | Prix | Dispo | Label |
|---|---|---|---|---|---|
| 10,8 | Les Ruchers du Hurepoix | Forges-les-Bains | 15,00 € | 50 | — |
| 21,1 ★ | Rucher de l'Essonne | La Ferté-Alais | 16,00 € | 60 | — |
| 28,7 ★ | Ferme des Quatre Vents | Gallardon | 15,50 € | 40 | — |

## Recherche 4 · Miel, rayon 45 km — montrer que le rayon change le résultat

5 fermes : les 3 ci-dessus, plus Rucher de l'Eure (Maintenon, 37,6 km, 14,00 €) et Ferme de l'Œuf
(Pithiviers, 42,1 km, 14,50 €). Passer le rayon de 30 à 45 km ajoute deux lignes, c'est la démonstration
du rayon en une phrase.

## Recherche 5 · Œufs, rayon 10 km — l'inverse

3 fermes, dont 2 favorites : Tilleuls (3,8), Poules de l'Orge (5,4), Coteau (7,5). Avec le rayon
minimum du formulaire (5 km), il n'en reste qu'une : les Tilleuls.

## Si un résultat ne correspond pas

- Une ferme manque : les seeds n'ont pas été rejouées sur cette base (`bin/rails db:seed`, idempotent).
- Une ferme en trop ou une distance différente : vérifier l'adresse de livraison choisie dans le
  formulaire (c'est elle qui sert au calcul, pas l'adresse du compte).
- Les ★ ne sont pas en tête : normal tant que la story 3 n'est pas fusionnée.
