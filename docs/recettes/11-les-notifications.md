# Story 9 — Les notifications (front #38)

Objectif : l'acheteur comme la ferme voient leurs notifications (commande reçue, acceptée, refusée ; besoin repéré, story 13) et ouvrent la commande ou les fermes concernées. Le compteur de la barre dit combien ne sont pas lues ; ouvrir la liste les marque lues. Même branche et même PR que le front (`Closes #11, closes #38`).

Les notifications sont déjà créées par les stories 5 et 6 (`Order#place`, `Order#accept!`) ; cette story ne fait que les filtrer, les afficher et les marquer lues. Aucune table ni migration.

## Sous-étapes

- [ ] 9.1 — Qui voit quoi, et la liste côté serveur
  - Fichiers : `app/policies/notification_policy.rb` (nouveau), `app/controllers/notifications_controller.rb`, `app/controllers/application_controller.rb` (compteur), `app/models/notification.rb` (`unread?`), `app/helpers/notifications_helper.rb` (nouveau), `test/policies/notification_policy_test.rb`, `test/helpers/notifications_helper_test.rb`, `test/fixtures/notifications.yml`
  - Technologie : `policy_scope(Notification)` passe par `NotificationPolicy::Scope#resolve`, qui ne garde que les lignes de l'utilisateur connecté (`where(user: user)`) ; c'est ce que `verify_policy_scoped` exige sur `index`. La liste est bornée (`.limit(50)`, les plus récentes d'abord). Marquer lues : une seule instruction SQL (`unread.update_all(read_at: Time.current)`), après avoir noté lesquelles étaient nouvelles pour les distinguer à l'écran. Le compteur de la barre est un `helper_method` d'`ApplicationController` (`unread_notifications_count`, mémorisé par requête) : la requête vit dans le contrôleur, pas dans le partial. Le lien vers la commande ou les fermes se construit depuis `notifiable_type` et `notifiable_id`, sans charger l'objet : aucune requête par ligne (Bullet n'a rien à dire).
  - Tests : la Scope rend les notifications de l'utilisateur et aucune autre ; un compte sans notification a une liste vide ; le helper donne `/orders/:id` pour une commande et `/needs/:id/matches` pour un besoin.
  - Vérification : `bin/rails runner 'p NotificationPolicy::Scope.new(User.first, Notification).resolve.count'`.
  - Estimation : ~70 lignes

- [ ] 9.2 — La liste et le compteur
  - Fichiers : `app/views/notifications/index.html.erb`, `app/views/notifications/_notification.html.erb`, `app/views/notifications/_counter.html.erb`, `config/locales/fr.yml` (`notifications.index.*`, `notifications.notification.*`), `test/integration/notifications_test.rb`
  - Technologie : Bootstrap `list-group` pour les lignes, pas de SCSS propre. Le libellé de chaque notification vient de l'enum (`notification.human_enum(:kind)`), la date de `l(created_at, format: :short)` (rails-i18n). Une notification qui vient d'être marquée lue porte l'étiquette « Nouvelle » (`tag tag--neutral`, charte). Le compteur : `<span class="site-navbar__counter">` (style déjà prêt), rien si zéro.
  - Tests : un visiteur est renvoyé vers la connexion ; la ferme voit sa « Commande reçue » et pas la notification de l'acheteur ; le compteur affiche « 1 » avant la visite et disparaît après ; la notification est marquée lue en base ; un compte sans notification voit le texte « Aucune notification ».
  - Vérification : connecté en ferme (`ferme1@…`), le compteur dans la barre ; cliquer « Notifications » → la liste, la ligne « Nouvelle », le lien ouvre la commande ; recharger → le compteur a disparu.
  - Estimation : ~90 lignes

## Points ouverts

- « Commande refusée » (`order_declined`) s'affichera dès que la story 10 créera ces notifications : rien à faire ici, le libellé existe déjà.
- Marquer lues à l'ouverture de la liste (et non au clic sur chaque ligne) : plus simple, et c'est ce que dit l'issue #11. Si l'équipe préfère un marquage ligne par ligne, c'est une route `member` de plus, donc une décision de cadrage.
- `bin/ci` ne tourne pas dans l'environnement de préparation (pas d'accès à rubygems) : premier `bin/ci` sur la machine de Silvère.
