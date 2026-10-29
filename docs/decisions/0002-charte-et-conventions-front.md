# 0002 · Charte graphique et conventions du front

Date : 28 octobre 2026 · Statut : proposée, à relire en équipe

## Contexte

La charte est dans Figma (fichier « Charte ») : une palette de 12 couleurs, des composants (boutons,
champ, étiquettes), une typographie (Inter), et des maquettes en couleur (barre du haut, résultats,
fiche ferme, pied de page). Chaque story a sa partie affichage. Pour que cinq personnes produisent des
écrans cohérents sans se marcher dessus, le socle pose une fois les couleurs, la police, les
composants partagés, la barre et le pied de page, et une convention de nommage.

## Décisions

| Sujet | Décision | Pourquoi |
|---|---|---|
| Source des couleurs | **La palette** (cadre « 1 — Palette »), et elle seule | Les maquettes en couleur s'en écartent légèrement : barre `#E2BC4A` au lieu du blé `#D9B44A`, pied de page `#2E5A3A` au lieu du sapin `#2E463A`, bandeau `#5A4033` au lieu de terre `#6E5443`. La palette est la seule source nommée. Si l'équipe préfère les teintes des maquettes, on change une ligne dans `config/_colors.scss`. |
| Où vivent les couleurs | `config/_colors.scss`, sous les noms de la charte | Un seul endroit à modifier ; `bin/controles` bloque un code couleur écrit ailleurs. |
| Personnaliser Bootstrap | Par ses variables (`config/_bootstrap_variables.scss`) et, pour la barre, par ses variables CSS (`--bs-navbar-…`) | C'est la méthode documentée par Bootstrap : ses composants restent cohérents entre eux, et une mise à jour de Bootstrap ne casse pas nos réécritures. Seule exception : les libellés de formulaire en capitales (`components/_forms.scss`), que Bootstrap ne règle par aucune variable. |
| Police | Inter, **hébergée chez nous** (`app/assets/fonts/`), un seul fichier `.woff2` variable | Aucun appel à Google Fonts ni à aucun service : l'adresse IP du visiteur n'est transmise à personne. Licence libre SIL OFL, jointe. |
| Boutons | `btn-primary` (sapin), `btn-outline-secondary` (contour terre), `btn-order` (blé) | Les deux premiers sont ceux de Bootstrap, connus de tous. Le troisième est nommé par sa fonction : la charte le réserve à « Commander ». |
| Nommage des classes | Classes de Bootstrap telles quelles ; les nôtres en anglais, par fonction, au format BEM (`site-navbar__link`, `tag--positive`) | Un nom de fonction se retrouve (« le bouton commander » → `btn-order`) et reste vrai si la couleur change. BEM dit d'un coup d'œil qu'une classe appartient à un bloc (`__`) ou en est une variante (`--`). |
| Étiquettes de statut | Un partial (`shared/_status_tag`) et une table statut → variante (`ApplicationHelper::STATUS_TONES`) | Le mot vient de `fr.yml`, la couleur de la table : personne ne choisit une couleur de statut à la main. La charte impose « une pastille et un mot ». |
| Prix | `format_price(cents)`, au format français de `rails-i18n` | Les prix sont en centimes en base ; un seul endroit pour les afficher. |
| Rubriques sans page | Grisées dans la barre, sans lien | La démo n'a pas de page « Annonces », « Mes commandes », « Fermes favorites ». Un lien vers une page absente mènerait à une erreur pendant la démo. |
| Pied de page | Rubriques en texte ; bandeau légal remplacé par la mention du projet | Pas de liens morts ; pas de fausses informations légales (société, RCS, adresse) sur un projet de démonstration. |
| Emplacements réservés | `notifications/_counter` (story 9), `shared/_sign_out_link` (story 14), vides avec un commentaire | La barre est commune : chacun remplit son fichier sans toucher au cadre, donc sans conflit. |

## Conséquences

- Chaque sous-tâche front reprend ces briques au lieu d'en recréer : boutons, étiquettes, `format_price`,
  cartes Bootstrap.
- En attendant la story 14, le menu du compte n'a pas de lien de déconnexion.
- Reste à faire, noté dans `docs/a-faire-plus-tard.md` : l'icône du site, et les rubriques à brancher.
