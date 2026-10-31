class OrdersController < ApplicationController
  # Story 4 (A03) : le récapitulatif avant envoi. Rien n'est écrit en base.
  def new
  end

  # Story 5 (A03 → A04) : crée la commande en pending et notifie la ferme.
  def create
  end

  # Story 7 (A05, BC) : la commande et son bon de commande (format PDF).
  def show
  end

  # Story 6 (V03) : la ferme accepte, le stock baisse.
  # controles: ok route member du cadrage (bloc 2)
  def accept
    @order = Order.find(params[:id])
    authorize @order

    @order.accept!
    redirect_to order_path(@order), notice: t(".success")
  rescue ActiveRecord::RecordInvalid
    redirect_to order_path(@order), alert: @order.errors.full_messages.to_sentence
  end

  # Story 10 (V03) : la ferme refuse.
  # controles: ok route member du cadrage (bloc 2)
  def decline
  end

  # Story 11 (A04) : l'acheteur annule tant que la commande est pending.
  # controles: ok route member du cadrage (bloc 2)
  def cancel
  end
end
