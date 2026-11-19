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
    # Retour à la page d'où vient le clic (la liste des fermes d'un besoin, ou les favoris).
    # need_matches_path(:need_id) construisait /needs/need_id/matches : un 404 masqué par Turbo.
    redirect_back_or_to favorites_path, notice: t(".success")
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
    redirect_back_or_to favorites_path, notice: t(".supprimer")
  end
end
# On doit pouvoir afficher nos fermes
# On doit pouvoir destroy une ferme
