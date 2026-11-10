# Où en est Ferme Directe

**Mis à jour le 10 novembre 2026, 10 h 30.** Ce fichier est réécrit à chaque fin de session de
coordination ; il dit l'état d'aujourd'hui, pas l'histoire. Le pourquoi des décisions est dans
`docs/decisions/` et dans l'historique du cadrage ; le détail de chaque story, dans `docs/recettes/`.

Demo Day : samedi 21 novembre. Parcours de démo : connexion → accueil → décrire un besoin → voir les
fermes → récapitulatif → commander → réponse de la ferme (simulée) → notification → bon de commande PDF
par e-mail.

## Qui fait quoi

| Qui | Stories | État |
|---|---|---|
| Marine | 1 (décrire son besoin), **4** (récapitulatif avant commande) | 1 sur `main` ; retouches de 1 en cours (voir ci-dessous) ; **4 pas commencée, la plus urgente du parcours** |
| Aurélien | 2 (voir les fermes), **3** (favorites en tête) | 2 sur `main` en version minimale (finition : filtre en SQL, droits, tests) ; 3 en cours ; à son initiative : bouton « ajouter en favori » et carte des résultats (à l'étude) |
| Kahina | 5 (commander), 6 (la ferme accepte) | sur `main` ; 10 (refuser) si elle a le temps, optionnelle |
| Marcio | 7 (commande confirmée + PDF), 8 (e-mail aux deux) | sur `main` |
| Silvère | 9 (notifications), 14 (connexion, accueil), charte, seeds, coordination | sur `main` |

Non assignées, optionnelles : 10 (refuser), 11 (annuler), 12 (Mes ventes), 13 (prévenir les fermes).

**Règle** : on ne touche pas à la story ou à la branche d'un autre sans son accord, voir `CLAUDE.md`.

## Sur `main` aujourd'hui

Stories 1, 2, 5, 6, 7, 8, 9, 14 ; seeds à 24 fermes et 4 favorites (rejouées en production le 9 nov.) ;
page « Pas encore ouvert » (`pages#soon`) rendue par `/sales` tant que la story 12 n'existe pas.
En ligne : https://ferme-directe.osc-fr1.scalingo.io (déploiement automatique à chaque fusion).

## En cours

- **Marine, formulaire du besoin** (même PR que ses retouches) : le champ d'adresse devient « Chercher autour
  de » et n'est jamais vide (une seule adresse → prise d'office) ; les phrases « seront prévenues »
  disparaissent ; **bug** : les `</div>` de `.need-form` et `.container` sont fermés avant `f.button :submit`,
  donc après un envoi refusé le bouton n'est plus dans le `<form>` et ne fait plus rien (cadrage v13, issue #3).
- **Aurélien, story 3** : bloc « Vos fermes favorites » séparé, étiquette `tag--favorite`, bouton favori
  (`resources :favorites, only: [:create, :destroy]`) ; carte des résultats à l'étude (Leaflet +
  OpenStreetMap, note de décision à écrire avant de coder) ; le panneau « Mes besoins en cours » ne
  s'affiche plus sur A02 (cadrage v15).
- PR ouvertes : #54 (règles d'équipe, ce fichier) ; #44 (Dependabot, Prawn 2.4 → 2.5 : après le 21).

## Décisions récentes

- 9 nov. : page d'accueil après connexion, plus d'inscription libre (cadrage v11).
- 9 nov. : adresse du besoin = point de départ du rayon, libellé « Chercher autour de » (v13).
- 9 nov. : le bouton reste « Voir les fermes » ; pas de notification aux fermes à l'enregistrement d'un
  besoin ; story 13 reste optionnelle (v14).
- 9 nov. : panneau « Mes besoins en cours » retiré de A02, gardé sur A01 comme rappel (v15).
- 9 nov. : seeds à 24 fermes, fiche des recherches de démo dans `docs/demo-recherches.md` (v12).

## Points ouverts

- Vérifier sur Scalingo que `SOLID_QUEUE_IN_PUMA` est défini, sinon les e-mails (`deliver_later`) ne partent pas.
- Panneau « Mes besoins en cours » sur A01 : à attribuer.
- Avertissement `libvips` au lancement en production : sans effet, à faire taire plus tard.
- Besoin de test n° 53 (Œufs, 300) créé en production le 9 nov. : à purger avant le 21.
