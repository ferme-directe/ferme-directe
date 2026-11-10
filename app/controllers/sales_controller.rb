# « Mes ventes » : les commandes où ma ferme est vendeuse. Pas de table sales : c'est une vue sur orders.
class SalesController < ApplicationController
  # Story 12 (V00), pas encore construite : on rend la page « Pas encore ouvert » au lieu de planter.
  # Rien n'est lu en base, donc rien à filtrer : skip_policy_scope le dit explicitement à Pundit.
  # Quand la story 12 arrive : policy_scope(Order) et la vue sales/index remplacent ces deux lignes.
  def index
    skip_policy_scope
    render "pages/soon"
  end
end
