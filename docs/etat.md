# Où en est Ferme Directe

**Mis à jour le 10 novembre 2026, 10 h 50.** Ce fichier est réécrit à chaque fin de session de
coordination ; il dit l'état d'aujourd'hui, pas l'histoire. Le pourquoi des décisions est dans
`docs/decisions/` et dans l'historique du cadrage ; le détail de chaque story, dans `docs/recettes/`.

Demo Day : samedi 21 novembre.

## Le parcours de démo, étape par étape

| Étape | Story | Qui | État |
|---|---|---|---|
| Connexion → page d'accueil | 14 | Silvère | en ligne |
| Décrire le besoin | 1 | Marine | en ligne ; retouches en cours (adresse, bouton) |
| Voir les fermes | 2, 3 | Aurélien | 2 en ligne (minimale) ; finition et favorites en tête en cours |
| **Récapitulatif avant commande** | **4** | **Marine** | **pas commencée : la seule étape manquante** |
| Commander → page « en attente » | 5 | Kahina | en ligne |
| « Simuler la réponse de la ferme » → acceptée | 6 + outil démo | Kahina | en ligne (`DEMO_MODE` à vérifier sur Scalingo) |
| Notification « commande acceptée » | 9 | Silvère | en ligne |
| Bon de commande PDF | 7 | Marcio | en ligne |
| E-mail aux deux, PDF joint | 8 | Marcio (code) · **Silvère (envoi)** | code en ligne ; **l'envoi n'est pas branché** (voir ci-dessous) |

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

## Prochaines étapes de Silvère (cette semaine)

1. **Brancher l'envoi d'e-mails** (story 8, côté exploitation). Aujourd'hui `production.rb` n'a pas de
   `smtp_settings` (bloc commenté), l'expéditeur est `bonjour@ferme-directe.test`, les variables
   `BREVO_SMTP_*` de `.env.example` ne sont lues nulle part : en production, `deliver_later` met l'e-mail
   en file et il ne part pas. À faire : compte Brevo, adresse d'expéditeur validée (`@ferme-directe.fr`,
   domaine Infomaniak), `delivery_method :smtp` vers `smtp-relay.brevo.com:587` avec identifiants en
   `ENV`, `raise_delivery_errors = true`, variables sur Scalingo, un envoi réel de test (`rails runner`).
   Marcio : rien à configurer ; le prévenir du nouvel expéditeur.
2. **Destinataires de démo** : les comptes des seeds ont des adresses fictives (`.test`), personne ne
   reçoit rien. Ne pas changer l'e-mail de `acheteur@…` (c'est le login) : ajouter un **second compte**
   à l'Épicerie du Moulin et un à la Ferme des Tilleuls, adresses lues dans `ENV` (`DEMO_BUYER_EMAIL`,
   `DEMO_FARM_EMAIL`), jamais en dur. L'e-mail part à chaque compte de l'entreprise.
3. Vérifier sur Scalingo : `DEMO_MODE` et `SOLID_QUEUE_IN_PUMA` définis
   (`scalingo --app ferme-directe --region osc-fr1 env | grep -E "DEMO|SOLID"`).
4. **Aucune page indexée** avant que le produit soit fini, le domaine `ferme-directe.fr` arrivant sur
   Scalingo : en-tête `X-Robots-Tag: noindex, nofollow` sur toutes les réponses
   (`config.action_dispatch.default_headers`, pages et PDF compris), balise `<meta name="robots">` dans
   le gabarit, `public/robots.txt` en `Disallow: /`, et un test qui vérifie l'en-tête et la balise.
   Dans la même PR que Brevo.
5. Vendredi 13 : si la story 4 n'a pas de PR, en parler avec Marine avant toute autre décision.

## Points ouverts

- Panneau « Mes besoins en cours » sur A01 : à attribuer.
- Avertissement `libvips` au lancement en production : sans effet, à faire taire plus tard.
- Besoin de test n° 53 (Œufs, 300) créé en production le 9 nov. : à purger avant le 21.
