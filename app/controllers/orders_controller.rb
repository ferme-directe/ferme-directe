class OrdersController < ApplicationController
  # Story 4 (A03) : le récapitulatif avant envoi. Rien n'est écrit en base.
  def new
  end

  # Story 5 (A03 → A04) : crée la commande en pending et notifie la ferme.
  # find lève une erreur 404 si le besoin ou l'offre n'existe pas (ou si l'offre n'est plus active).
  def create
    need = Listing.need.find(params[:need_id])
    offer = Listing.offer.active.find(order_params[:offer_id])
    @order = Order.build_from(need: need, offer: offer, quantity: order_params[:quantity] || need.quantity)
    authorize @order

    if @order.place
      redirect_to order_path(@order), notice: t(".success")
    else
      redirect_to need_matches_path(need), alert: t(".failure")
    end
  end

  # Story 7 (A05, BC) : la commande et son bon de commande (format PDF).
  def show
  end

  # Story 6 (V03) : la ferme accepte, le stock baisse.
  # controles: ok route member du cadrage (bloc 2)
  def accept
  end

  # Story 10 (V03) : la ferme refuse.
  # controles: ok route member du cadrage (bloc 2)
  def decline
  end

  # Story 11 (A04) : l'acheteur annule tant que la commande est pending.
  # controles: ok route member du cadrage (bloc 2)
  def cancel
  end

  private

  # Ce que le formulaire de la story 4 envoie : l'offre choisie et la quantité.
  def order_params
    params.expect(order: %i[offer_id quantity])
  end
end
