# Le besoin de l'acheteur : une ligne de listings avec kind: need.
class NeedsController < ApplicationController
  # Story 1 (A01) : affiche le formulaire. Lit products et les adresses de l'entreprise.
  def new
  end

  # Story 1 (A01) : enregistre le besoin, puis redirige vers /needs/:id/matches.
  # Story 13 : prévient ensuite les fermes qui peuvent le servir.
  def create
  end
end
