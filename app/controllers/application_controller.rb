class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # Pundit : chaque action doit vérifier les droits (authorize) ou filtrer la liste (policy_scope).
  # Une action qui oublie lève une erreur en développement et en test : l'oubli ne passe pas inaperçu.
  include Pundit::Authorization

  # Un seul callback, sans only: ni except:, comme le recommande le README de Pundit.
  # Avec only: :index, Rails (depuis 7.1) lève une erreur sur tout contrôleur sans action index.
  after_action :verify_pundit_authorization, unless: :skip_pundit?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def verify_pundit_authorization
    if action_name == "index"
      verify_policy_scoped
    else
      verify_authorized
    end
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def user_not_authorized
    flash[:alert] = "Vous n'avez pas accès à cette page."
    redirect_back_or_to(root_path)
  end
end
