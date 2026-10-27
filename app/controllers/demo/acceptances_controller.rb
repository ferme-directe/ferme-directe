# Outil de démo, pas une story : « Simuler la réponse de la ferme » (A04).
# Appelle la même méthode que le bouton de la ferme (order.accept!, story 6).
# Route déclarée seulement si DEMO_MODE est défini (config/routes.rb).
module Demo
  class AcceptancesController < ApplicationController
    def create
    end
  end
end
