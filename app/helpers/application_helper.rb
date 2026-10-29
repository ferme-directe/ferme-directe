# Les méthodes d'affichage partagées par toutes les vues.
# Un helper sert à garder les vues lisibles : la logique (calcul, choix d'une
# classe) est ici, testée une fois (test/helpers/application_helper_test.rb),
# et la vue se contente de l'appeler.
module ApplicationHelper
  # Un prix en centimes (comme en base) affiché en euros, au format français
  # fourni par la gem rails-i18n :
  #   format_price(36)      # => "0,36 €"
  #   format_price(10_800)  # => "108 €"     un prix rond s'affiche sans « ,00 », comme la maquette
  #   format_price(100_000) # => "1 000 €"
  # Toutes les vues passent par ici : le jour où le format change, une seule ligne bouge.
  def format_price(cents)
    precision = (cents % 100).zero? ? 0 : 2
    number_to_currency(cents / 100.0, precision: precision)
  end

  # La variante de l'étiquette de statut (.tag--… dans components/_tag.scss),
  # selon le statut d'un enregistrement : une commande, une annonce.
  # Une seule table pour tous les modèles : un nouveau statut = une ligne ici.
  STATUS_TONES = {
    "pending" => "waiting",    # Order : en attente
    "accepted" => "positive",  # Order : acceptée
    "declined" => "negative",  # Order : refusée
    "cancelled" => "negative", # Order : annulée
    "active" => "positive",    # Listing : en ligne
    "closed" => "negative"     # Listing : terminée
  }

  # fetch (et non [ ]) lève une erreur si un statut manque dans la table :
  # l'oubli casse un test, au lieu d'afficher en silence une étiquette sans couleur.
  def status_tone(record)
    STATUS_TONES.fetch(record.status)
  end

  # Les initiales du rond du compte, dans la barre du haut :
  #   Paul Durand  # => "PD"
  #   sans prénom ni nom, la première lettre de l'e-mail.
  def user_initials(user)
    initials = [user.first_name, user.last_name].compact_blank.map { |name| name[0] }.join
    (initials.presence || user.email[0]).upcase
  end

  # Une rubrique de la barre du haut. Trois cas :
  # - pas encore de page (path: nil) : la rubrique est grisée, sans lien.
  #   Elle devient un lien quand sa story crée la route ; pas de lien qui mène à une erreur ;
  # - la page affichée est celle de la rubrique (ou active: true) : en gras et soulignée,
  #   et aria-current dit aux lecteurs d'écran « vous êtes ici » ;
  # - sinon, un lien normal.
  def nav_link_to(label, path, active: false)
    classes = %w[nav-link site-navbar__link]
    return tag.span(label, class: classes + ["disabled"], aria: { disabled: true }) if path.nil?

    active ||= current_page?(path)
    link_to label, path, class: classes + (active ? ["active"] : []), aria: { current: (active ? "page" : nil) }
  end
end
