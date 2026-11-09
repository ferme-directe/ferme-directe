# Story 14 — Se connecter, se déconnecter, page d'accueil (front #39)

Objectif : un visiteur ne voit que la connexion ; une fois connecté, il arrive sur la page d'accueil, qui dit ce qu'est Ferme Directe et ouvre deux portes, « J'achète » et « Je vends ». Les pages de Devise sont en français et sur la charte, le lien de déconnexion est dans le menu du compte. Même branche et même PR que le back (`Closes #24, closes #39`).

Changement de décision (9 nov.) : la décision du 28 oct. envoyait l'utilisateur connecté sur « De quoi avez-vous besoin ? » (`/needs/new`). Les retours de la démo du 5 nov. demandent une page d'accueil d'abord. `pages#home` est donc **gardé et rempli**, au lieu d'être supprimé ; la racine `/` reste `pages#home`. L'issue #24, la sous-tâche #39 et la note `docs/decisions/0001` sont mis à jour dans cette PR.

## Sous-étapes

- [x] 14.1 — L'accueil réservé aux connectés, plus d'inscription
  - Fichiers : `app/controllers/pages_controller.rb`, `app/models/user.rb`, `app/views/devise/registrations/` (supprimé), `test/integration/pages_test.rb`, `docs/decisions/0001-ecarts-du-template.md`
  - Technologie : `before_action :authenticate_user!` est déjà posé dans `ApplicationController` ; `pages#home` s'en exemptait (`skip_before_action`). On retire l'exemption : Devise renvoie le visiteur vers `/users/sign_in`, puis le ramène sur `/` après connexion (c'est la racine, destination par défaut de Devise). Retirer `:registerable` du modèle supprime les routes et le lien « Sign up » : l'inscription avec création d'entreprise est hors démo (cadrage).
  - Tests : un visiteur sur `/` est redirigé vers la connexion ; un utilisateur connecté obtient la page ; la route d'inscription n'existe plus.
  - Vérification : déconnecté, ouvrir `/` → page de connexion ; se connecter avec `acheteur@ferme-directe.test` → retour sur `/`.
  - Estimation : ~45 lignes

- [x] 14.2 — La page d'accueil
  - Fichiers : `app/views/pages/home.html.erb`, `config/locales/fr.yml` (`pages.home.*`), `app/assets/stylesheets/pages/_home.scss` et son import dans `pages/_index.scss`, `app/assets/images/logo-ferme-directe.svg`, `test/integration/pages_test.rb`
  - Technologie : la maquette « Accueil Ferme Directe » (canevas Claude, 9 nov.). Bootstrap pour la grille (`row`, `col-lg-6`, `card`, `btn`), la charte pour les couleurs (variables de `config/_colors.scss`, jamais un code couleur dans la page). Le logo est un fichier SVG servi par Propshaft via `image_tag`. Les textes passent tous par `t()`.
  - Boutons : `btn btn-primary btn-lg` pour « Décrire mon besoin » (`new_need_path`), `btn btn-outline-secondary` pour « Voir mes ventes » (`sales_path`, même cible que la bascule de la barre).
  - Tests : connecté, la page contient le titre, les deux boutons avec leurs cibles, et le logo (`img[alt]`).
  - Vérification : connecté, ouvrir `/` → logo, titre, trois étapes, deux cartes, encadré « Un seul compte, deux rôles ». Largeur téléphone : les cartes s'empilent, rien ne déborde.
  - Estimation : ~130 lignes (dont ~45 de SVG)

- [x] 14.3 — Connexion en français, sur la charte, et déconnexion
  - Fichiers : `app/views/devise/sessions/new.html.erb`, `devise/passwords/new.html.erb`, `devise/passwords/edit.html.erb`, `devise/shared/_links.html.erb`, `devise/shared/_auth_header.html.erb` (nouveau), `devise/mailer/reset_password_instructions.html.erb` (traduit ; `email_changed` et `password_change`, notifications désactivées, supprimés), `app/views/shared/_sign_out_link.html.erb`, `config/locales/fr.yml` (`shared.sign_out_link.*`), `bin/controles`, `test/integration/layout_test.rb`
  - Technologie : les libellés viennent de `devise-i18n` (clés `devise.sessions.new.sign_in`, `devise.passwords.new.forgot_your_password`, `devise.shared.links.*`…), lus par `t(".sign_in")` en recherche paresseuse : on n'écrit aucune traduction Devise nous-mêmes. Formulaire Simple Form dans une `card` centrée (`mx-auto`, `col-md-6 col-lg-4`), bouton principal `btn btn-primary btn-lg w-100`. Déconnexion : `button_to` en `DELETE` (un formulaire, pas un lien : se déconnecter change l'état). Les vues Devise rentrent dans le contrôle des textes : on retire `--exclude-dir=devise` de `bin/controles`.
  - Tests : connecté, le menu du compte contient le bouton « Se déconnecter » en `DELETE` vers `/users/sign_out` ; la page de connexion affiche « Connexion » et le lien « Mot de passe oublié ? ».
  - Vérification : `/users/sign_in` en français sur la charte ; mauvais mot de passe → message en français ; menu du compte → « Se déconnecter » → retour à la connexion.
  - Estimation : ~95 lignes

- [x] 14.4 — Le logo dans la barre du haut
  - Fichiers : `app/assets/images/logo-ferme-directe-toit.svg`, `app/views/shared/_navbar.html.erb`, `app/assets/stylesheets/components/_brand.scss`
  - Technologie : en dessous de 48 px, le logo se réduit au toit seul (règle de la maquette). La pastille CSS (`@include dot`) de `.site-brand` est remplacée par l'image dans la barre ; le pied de page garde sa pastille blé (`.site-brand--on-dark`), le toit en clair sur sapin viendra avec l'icône du site (à-faire).
  - Tests : `layout_test` reste vert (`.site-brand` contient toujours le texte « Ferme Directe »).
  - Vérification : la barre montre le toit puis « Ferme Directe » ; 40 px de haut, aligné sur les rubriques.
  - Estimation : ~30 lignes

## Points ouverts

- « Je vends » mène à `sales_path` (story 12, action encore vide → erreur Pundit tant qu'elle n'est pas écrite), comme la bascule de la barre aujourd'hui. Pour la démo du 21, soit la story 12 existe, soit on dirige ce bouton ailleurs : à trancher avec l'équipe. → option retenue : `sales_path`, une seule cible pour « Je vends » dans toute l'application.
- Le slogan du pied de page (« De nouveaux débouchés pour les fermes françaises ») ne parle qu'aux fermes ; la maquette propose « Moins de démarches pour les professionnels, des débouchés au juste prix pour les producteurs ». Non tranché : la clé `shared.footer.tagline` n'est pas touchée ici.
- `bin/ci` ne peut pas tourner dans l'environnement de préparation (pas d'accès à rubygems) : les tests sont écrits et relus, mais le premier `bin/ci` vert sera celui de la machine de Silvère, avant d'ouvrir la PR.
