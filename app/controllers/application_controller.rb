class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # Pundit : chaque action doit vérifier les droits (authorize) ou filtrer la liste (policy_scope).
  # Une action qui oublie lève une erreur en développement et en test : l'oubli ne passe pas inaperçu.
  include Pundit::Authorization

  # Un seul callback, sans only: ni except:, comme le recommande le README de Pundit.
  # Avec only: :index, Rails (depuis 7.1) lève une erreur sur tout contrôleur sans action index.
  after_action :verify_pundit_authorization, unless: :skip_pundit?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Le compteur de la barre du haut (story 9) : visible par les vues comme current_user.
  # La requête vit ici, pas dans le partial, et elle n'est faite qu'une fois par page.
  helper_method :unread_notifications_count

  private

  def unread_notifications_count
    @unread_notifications_count ||= current_user.notifications.unread.count
  end

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
