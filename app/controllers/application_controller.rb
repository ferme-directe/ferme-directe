class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # Pundit : chaque action doit vérifier les droits (authorize) ou filtrer la liste (policy_scope).
  # Une action qui oublie lève une erreur en développement et en test : l'oubli ne passe pas inaperçu.
  include Pundit::Authorization
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def user_not_authorized
    flash[:alert] = "Vous n'avez pas accès à cette page."
    redirect_back_or_to(root_path)
  end
end
