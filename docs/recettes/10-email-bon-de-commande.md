# Story 10 — E-mail du bon de commande (front #37)

Objectif : l'e-mail de confirmation, en HTML et en texte, reprend le bon de commande (les deux parties, la date, le produit, les prix) et rappelle que le PDF est joint. Même branche et même PR que le back (`Closes #10, closes #37`).

Le back est déjà sur cette branche : `OrderMailer#confirmation` joint le PDF et l'envoie à l'acheteur et à la ferme. Le front n'ajoute pas d'envoi.

## Sous-étapes

- [ ] 10.1 — Corps de l'e-mail, HTML et texte
  - Fichiers : `app/views/layouts/mailer.html.erb`, `app/views/order_mailer/confirmation.html.erb`, `app/views/order_mailer/confirmation.text.erb`, `app/mailers/order_mailer.rb` (`helper ApplicationHelper`), `config/locales/fr.yml` (`order_mailer.confirmation.*`), `test/mailers/order_mailer_test.rb`
  - Technologie : les clients mail n'acceptent que des styles inline. sapin, terre et trait sont recopiés en dur, commentés avec leur nom de charte. Les prix passent par `format_price`. Le PDF joint ne change pas : sa mise en page est la story 7, sur l'autre branche.
  - Tests : le corps HTML et le corps texte contiennent la référence, l'acheteur, la ferme, « 0,36 € » et « 108 € ». Les tests d'envoi et de pièce jointe restent verts.
  - Vérification : en développement, l'e-mail s'ouvre via letter_opener. On y voit le titre, les deux parties, le tableau de prix, et la phrase sur le PDF joint.
  - Estimation : ~80 lignes

## Points ouverts

- Le PDF joint est celui déjà généré sur cette branche, pas la version « couleurs de la charte » commitée sur la story 7. Les deux branches n'ont pas encore été fusionnées.
