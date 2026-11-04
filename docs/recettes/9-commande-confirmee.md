# Story 9 — Commande confirmée, bon de commande (front #36)

Objectif : sur la page d'une commande acceptée, le panneau de droite confirme la commande et propose le téléchargement du PDF. Le PDF reste sobre, avec les trois couleurs de la charte recopiées une fois dans la classe Prawn. Même branche et même PR que le back (`Closes #9, closes #36`).

Le back est déjà sur cette branche (page `show` et `PurchaseOrderPdf`). Le front ne réécrit pas ce parcours : il habille l'affichage.

## Sous-étapes

- [ ] 9.1 — Panneau « acceptée » et lien PDF
  - Fichiers : `app/views/orders/status/_accepted.html.erb`, `config/locales/fr.yml` (`orders.status.accepted.*`), `test/integration/orders_show_test.rb`
  - Technologie : le cadre de la page (`orders/show`) et le récapitulatif (`orders/_summary`) viennent de la story 5. Ce partial ne fait qu'afficher le texte et le bouton. Le statut « Acceptée » reste dans `shared/status_tag`, déjà posé par le cadre.
  - Bouton : `link_to t(".download"), order_path(order, format: :pdf), class: "btn btn-primary btn-lg"`. Prix via `format_price` s'il apparaît ici ; aucun calcul dans la vue.
  - Tests : une commande acceptée affiche le lien « Télécharger le bon de commande » avec la classe du bouton principal ; le mot « Acceptée » n'apparaît qu'une fois (l'étiquette du cadre).
  - Vérification : connecté comme l'acheteur, ouvrir une commande acceptée → titre, étiquette, récapitulatif à gauche, bouton sapin à droite ; le lien télécharge le PDF. Largeur téléphone : les deux colonnes s'empilent.
  - Estimation : ~40 lignes

- [ ] 9.2 — PDF sobre aux couleurs de la charte
  - Fichiers : `app/pdfs/purchase_order_pdf.rb`, clés PDF dans `config/locales/fr.yml` si un libellé manque
  - Technologie : Prawn ne lit pas le SCSS. Les trois couleurs utiles (sapin `#2E463A`, terre `#6E5443`, trait `#E4DDD0`) vivent **une fois** dans une constante commentée de la classe, avec leur nom de charte. Titre = nom du site, tableau `prawn-table` (produit, quantité, prix, total), les deux parties, la date. Textes par `I18n.t`.
  - Tests : le test d'intégration existant reste vert (réponse `application/pdf`, nom de fichier = référence). On ne parse pas le dessin du PDF.
  - Vérification : télécharger le PDF → titre, tableau, acheteur, ferme, date, filet terre / sapin lisible.
  - Estimation : ~50 lignes

## Points ouverts

- Le cadre (`orders/show`, `orders/_summary`, partials `orders/status/` vides sauf `_pending`) a été recopié depuis `7-story-5-envoyer-la-commande`, sans fusionner cette branche : son back (création de commande) n'est pas dans cette PR. La page `show` du back de la story 7 est remplacée par ce cadre.
- La story 8 (e-mail, #37) est une autre branche (`10-story-8-e-mail-avec-le-pdf-aux-deux`). Elle n'est pas dans cette recette.
