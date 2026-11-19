# Les visuels de la charte : l'icône d'un produit, l'avatar d'une entreprise (ferme ou acheteur).
# Les fichiers SVG sont dans app/assets/images/produits, fermes et acheteurs, dessinés dans le style
# du logo (formes simples, contour terre). Leurs couleurs sont écrites dans les SVG, comme pour le
# logo : un SVG ne lit pas le SCSS.
# Pourquoi des dessins et pas des photos : docs/decisions/0004-visuels-produits-et-fermes.md
module VisualsHelper
  # Le dessin d'une ferme, selon son produit principal (sa première offre).
  # Clé : le nom du produit, comme pour les icônes ; valeur : le fichier dans images/fermes.
  FARM_KINDS = {
    "oeufs" => "poulailler", "poulet-entier" => "poulailler",
    "miel" => "rucher",
    "farine-de-ble" => "cereales", "farine-d-epeautre" => "cereales", "lentilles" => "cereales",
    "pommes-de-terre" => "maraichage", "carottes" => "maraichage", "poireaux" => "maraichage",
    "oignons" => "maraichage", "courges" => "maraichage",
    "pommes" => "verger", "poires" => "verger",
    "lait-cru" => "laiterie", "fromage-de-chevre" => "laiterie"
  }.freeze
  DEFAULT_FARM_KIND = "cereales".freeze

  # Le dessin d'un acheteur, selon le début de son code NAF (companies.naf_code, « 5610A » ou
  # « 56.10A ») ; sans code, ou un code non prévu : l'épicerie.
  BUYER_KINDS = { "56" => "restaurant", "1071" => "boulangerie" }.freeze
  DEFAULT_BUYER_KIND = "epicerie".freeze

  # <%= product_icon(order.product) %> : l'icône du produit, 24 px par défaut.
  # Décorative : le nom du produit est toujours écrit à côté, donc alt vide.
  # Un produit sans icône (ajouté plus tard au référentiel) n'affiche rien, la page ne plante pas.
  def product_icon(product, size: 24, css: nil)
    path = "produits/#{visual_slug(product)}.svg"
    return unless visual_exists?(path)

    image_tag(path, alt: "", width: size, height: size, class: ["product-icon", css].compact.join(" "))
  end

  # <%= company_avatar(listing.company) %> : le rond qui représente l'entreprise, 48 px par défaut.
  # Une ferme a le dessin de sa production, un acheteur celui de son commerce.
  # Décoratif : le nom de l'entreprise est écrit à côté.
  # Le jour où companies.photos existera (Active Storage, formulaire d'inscription F-A, hors démo),
  # la photo passera ici avant le dessin, et les vues n'auront rien à changer.
  def company_avatar(company, size: 48, css: nil)
    image_tag(avatar_path(company), alt: "", width: size, height: size,
                                    class: ["company-avatar", css].compact.join(" "))
  end

  # Le rond du compte, dans la barre du haut : l'avatar de l'entreprise de l'utilisateur,
  # ou ses initiales s'il n'est rattaché à aucune entreprise.
  def account_avatar(user)
    user.company ? company_avatar(user.company, size: 36) : user_initials(user)
  end

  # Les couleurs des points de la carte (page des fermes), prises dans la charte (config/_colors.scss) :
  # comme un SVG, la carte JavaScript ne lit pas le SCSS. Fermes : $sapin ; le lieu du besoin : $terre.
  MAP_COLORS = { farm: "#2E463A", need: "#6E5443" }.freeze

  def map_color(kind)
    MAP_COLORS.fetch(kind)
  end

  # « Farine d'épeautre » → « farine-d-epeautre » : le nom du fichier vient du nom du produit.
  def visual_slug(product)
    product&.name.to_s.parameterize
  end

  private

  def avatar_path(company)
    if company.can_sell?
      "fermes/#{FARM_KINDS.fetch(visual_slug(company.main_offer&.product), DEFAULT_FARM_KIND)}.svg"
    else
      naf = company.naf_code.to_s.delete(".")
      "acheteurs/#{BUYER_KINDS.find { |prefix, _| naf.start_with?(prefix) }&.last || DEFAULT_BUYER_KIND}.svg"
    end
  end

  # Propshaft sait si un fichier existe parmi les images : on vérifie avant d'appeler image_tag,
  # qui lèverait une erreur sur un fichier absent.
  def visual_exists?(path)
    Rails.application.assets.load_path.find(path).present?
  end
end
