# Où en est Ferme Directe

**Mis à jour le 12 novembre 2026, 18 h 30.** Ce fichier est réécrit à chaque fin de session de
coordination ; il dit l'état d'aujourd'hui, pas l'histoire. Le pourquoi des décisions est dans
`docs/decisions/` et dans l'historique du cadrage ; le détail de chaque story, dans `docs/recettes/`.

Demo Day : samedi 21 novembre.

## Le parcours de démo, étape par étape

| Étape | Story | Qui | État |
|---|---|---|---|
| Connexion → page d'accueil | 14 | Silvère | en ligne |
| Décrire le besoin | 1 | Marine | en ligne ; correction du bouton d'envoi (hors du formulaire après une erreur) dans la PR #59 |
| Voir les fermes, favorites en tête | 2, 3 | Aurélien | sur `main` (PR #58) ; corrections en cours, dont les liens « favori » et « Commander » (voir « En cours ») |
| Récapitulatif avant commande | 4 | Marine | PR #59, CI verte, en attente de relecture |
| Commander → page « en attente » | 5 | Kahina | en ligne |
| « Simuler la réponse de la ferme » → acceptée | 6 + outil démo | Kahina | en ligne (`DEMO_MODE` à vérifier sur Scalingo) |
| Notification « commande acceptée » | 9 | Silvère | en ligne |
| Bon de commande PDF | 7 | Marcio | en ligne |
| E-mail aux deux, PDF joint | 8 | Marcio (code) · **Silvère (envoi)** | code en ligne ; **l'envoi n'est pas branché** (voir ci-dessous) |

## Qui fait quoi

| Qui | Stories | État |
|---|---|---|
| Marine | 1 (décrire son besoin), 4 (récapitulatif avant commande) | 1 sur `main` ; 4 en PR (#59) |
| Aurélien | 2 (voir les fermes), 3 (favorites en tête) | sur `main` ; **une PR de correction de la story 3 à ouvrir** |
| Kahina | 5 (commander), 6 (la ferme accepte) | sur `main` ; 10 (refuser) si elle a le temps, optionnelle |
| Marcio | 7 (commande confirmée + PDF), 8 (e-mail aux deux) | sur `main` |
| Silvère | 9 (notifications), 14 (connexion, accueil), charte, seeds, méthode, coordination | sur `main` |

Non assignées, optionnelles : 10 (refuser), 11 (annuler), 12 (Mes ventes), 13 (prévenir les fermes).

**Règle** : on ne touche pas à la story ou à la branche d'un autre sans son accord, voir `CLAUDE.md`.

## Sur `main` aujourd'hui

Stories 1, 2, 3, 5, 6, 7, 8, 9, 14 ; seeds à 24 fermes et 4 favorites (rejouées en production le 9 nov.) ;
page « Pas encore ouvert » (`pages#soon`) rendue par `/sales` tant que la story 12 n'existe pas.
En ligne : https://ferme-directe.osc-fr1.scalingo.io (déploiement automatique à chaque fusion).

**La CI de `main` est rouge** depuis le 11 nov. : deux remarques RuboCop de forme dans `matches_controller.rb`,
déjà corrigées dans la #59 ; `main` repasse au vert quand la #59 est fusionnée.

## En cours

- **Story 3, correction (Aurélien)** : une issue de bug liée à la story 3, une branche `fix/…` depuis `main`,
  un test par point (protocole dans le skill `rails-methode`, « Corriger une story déjà fusionnée »). Les points
  relevés le 12 nov. :
  1. le lien « ajouter en favori » renvoie vers une adresse introuvable : `need_matches_path(:need_id)` met le
     mot « need_id » dans l'adresse (`favorites_controller.rb`, lignes 13 et 26) ;
  2. « Commander » renvoie une erreur : `button_to … need_matches_path` envoie un POST vers une route GET seulement
     (`matches/index.html.erb`, ligne 56) ; le bon lien est `new_need_order_path(@need, offer_id: listing.id)` ;
  3. vérifier que le besoin affiché appartient à l'utilisateur connecté : `authorize` sur le besoin (`matches_controller.rb`) ;
  4. affichage des prix et du total par `format_price` (lignes 51, 53) ;
  5. n'afficher que les offres actives, comme la page de la story 4 : filtre `active` dans la requête ;
  6. les tests de la story, et un texte de la vue à passer par `t()`.
- **Jonction stories 3 et 4 (Aurélien et Marine, à deux)** : qui écrit la ligne « Commander », le nom
  `offer_id`, les offres actives des deux côtés, un seul calcul de prix, et l'ordre de fusion : la #59
  d'abord, puis la correction de la story 3 depuis `main` à jour.
- **Story 4, PR #59 (Marine)** : CI verte, à relire. À compléter, dans la PR ou dans une issue de suite :
  les tests, le titre du partial partagé `orders/_summary` (utilisé aussi par la story 5), `Closes #6`.
  La #59 touche aussi deux lignes de forme dans `matches_controller.rb` : à coordonner avec la story 3.
- **Méthode (Silvère)** : PR #60 (longueur des méthodes signalée sans bloquer au-delà de 12 lignes, filtres
  en Ruby et chemins avec un symbole signalés à relire, protocole de correction, modèle de PR) ; PR #57
  (ce fichier, règle des rôles). Après la correction de la story 3 : passer en bloquant les contrôles des
  textes en dur et des chemins avec un symbole.
- PR ouvertes ailleurs : #61 (RuboCop de Rails, `rubocop-rails-omakase`, en brouillon : après le 21) ;
  #44 (Dependabot, Prawn 2.4 → 2.5 : après le 21).

## Décisions récentes

- 12 nov. : la longueur des méthodes est un signal, pas un blocage (RuboCop, niveau `info`, au-delà de 12 lignes).
- 12 nov. : une story fusionnée ne se rouvre pas ; un bug trouvé après coup a son issue, sa branche `fix/…`,
  son test de non-régression, et sa PR avec `Fixes #N`.
- 12 nov. : la dérogation de fusion (contournement de la règle de `main`) sert une dernière fois pour la #60
  et la #57 (configuration et documentation, aucun code de l'application), puis est retirée.
- 9 nov. : page d'accueil après connexion, plus d'inscription libre (cadrage v11).
- 9 nov. : adresse du besoin = point de départ du rayon, libellé « Chercher autour de » (v13).
- 9 nov. : le bouton reste « Voir les fermes » ; pas de notification aux fermes à l'enregistrement d'un
  besoin ; story 13 reste optionnelle (v14).

## Prochaines étapes de Silvère

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
4. **Aucune page indexée** avant que le produit soit fini : en-tête `X-Robots-Tag: noindex, nofollow` sur
   toutes les réponses (`config.action_dispatch.default_headers`), balise `<meta name="robots">` dans le
   gabarit, `public/robots.txt` en `Disallow: /`, et un test. Dans la même PR que Brevo.
5. Après la fusion de la #60 et de la #57 : retirer le contournement de la règle de `main` (Settings → Rules).
6. Supprimer la branche `chore/regle-branche-de-l-auteur` (déjà fusionnée dans la #54).

## Points ouverts

- Panneau « Mes besoins en cours » sur A01 : à attribuer.
- Avertissement `libvips` au lancement en production : sans effet, à faire taire plus tard.
- Besoin de test n° 53 (Œufs, 300) créé en production le 9 nov. : à purger avant le 21.
- La clé `config/master.key` a été visible sur une capture d'écran le 10 nov. : à renouveler.
