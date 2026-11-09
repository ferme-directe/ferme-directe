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

  # « Pas encore ouvert » : la page des parties qui ne sont pas encore construites (story 12
  # aujourd'hui). Un contrôleur sans story rend cette vue au lieu de planter ; le jour où la
  # story arrive, il la remplace par la sienne. Textes : pages.soon.* (clés absolues, pour que
  # la vue se rende depuis n'importe quel contrôleur).
  # controles: ok page « bientôt » (pages#soon), hors CRUD par décision du 9 nov.
  def soon
  end
end
