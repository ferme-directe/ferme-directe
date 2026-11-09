# La page d'accueil, après connexion (story 14, décision du 9 nov. : elle remplace
# le renvoi direct vers « De quoi avez-vous besoin ? »).
# authenticate_user! vient d'ApplicationController : un visiteur est renvoyé vers la
# connexion, et Devise le ramène ici ensuite (la racine est sa destination par défaut).
# Pundit est exempté pour ce contrôleur (ApplicationController#skip_pundit?) : la page
# n'affiche aucune donnée appartenant à un compte, seulement des liens.
class PagesController < ApplicationController
  # controles: ok page d'accueil (pages#home), hors CRUD par décision du socle
  def home
  end
end
