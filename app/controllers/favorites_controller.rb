class FavoritesController < ApplicationController
  # On vérifie que l'utilsateur est connecté
  before_action :authenticate_user!
  # On doit pouvoir créer un favoris
  def create
    @favorite = current_user.company.favorites.new
    # On récupère le favoris de l'utilisateur a partir des params ajouté à notre view
    @favorite.favorite_company_id = params[:favorite_company_id]
    # cette ligne uniquement est proposée par L'ia car je ne connais pas authorize
    authorize @favorite
    # On doit pouvoir sauvegader notre favoris
    @favorite.save
    redirect_to need_matches_path(:need_id), notice: "ajouté aux favoris"
  end

  def index
    # partie IA car mon code initial ne passait pas à cause de policy scope et je n'avais pas la solution
    @favorites = policy_scope(Favorite)
  end

  def destroy
    @favorite = current_user.company.favorites.find(params[:id])
    # cette ligne uniquement est proposée par L'ia car je ne connais pas authorize
    authorize @favorite
    @favorite.destroy
    redirect_to need_matches_path(:need_id), notice: " Favoris supprimé"
  end
end
# On doit pouvoir afficher nos fermes
# On doit pouvoir destroy une ferme
