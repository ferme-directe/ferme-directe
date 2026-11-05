# Les fermes qui correspondent à un besoin. Pas de table : c'est une recherche sur listings.
class MatchesController < ApplicationController
  # Stories 2 et 3 (A02) : les offres compatibles dans le rayon, favorites en tête.
  def index
    # on doit récpèrer tous les listings offres et besoins
    # On les enregistre dans une variable d'instance
    @listings = policy_scope(Listing)
    # On filtre listing pour récupérer uniquement les offres
    @listings = @listings.select { |listing| listing.kind == "offer" }
    # On récupère le besoin de l'utilisateur par son id
    @need = Listing.find(params[:need_id])
    # on filtre une nouvelle fois et on compare les produits et les besoins
    @listings = @listings.select { |listing| listing.product == @need.product }
    # On récupère l'addresse de l'utilsateur
    @need_address = @need.address

    # On doit géocoder maintenant en comparant l'address de l'utilisateur avec les Address des fermes en base de données
    @near_address = Address.near(@need_address, 40)
    # On compare toutes nos offres pour voir si les offres matchs en utilsant .include? comme méthode.
    @listings = @listings.select { |listing| @near_address.include?(listing.address) }
  end
end
