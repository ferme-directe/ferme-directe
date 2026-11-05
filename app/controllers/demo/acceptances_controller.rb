# Outil de démo, pas une story : « Simuler la réponse de la ferme » (A04).
# Appelle la même méthode que le bouton de la ferme (order.accept!, story 6).
# Route déclarée seulement si DEMO_MODE est défini (config/routes.rb).
module Demo
  class AcceptancesController < ApplicationController
    def create
      @order = Order.find(params[:order_id])
      authorize @order, :demo_accept?

      @order.accept!
      redirect_to order_path(@order), notice: t("orders.accept.success")
    rescue ActiveRecord::RecordInvalid
      redirect_to order_path(@order), alert: @order.errors.full_messages.to_sentence
    end
  end
end
