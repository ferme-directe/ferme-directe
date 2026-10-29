class OrdersController < ApplicationController
  # Story 4 (A03) : le récapitulatif avant envoi. Rien n'est écrit en base.
  def new
  end

  # Story 5 (A03 → A04) : crée la commande en pending et notifie la ferme.
  def create
  end

  # Story 7 (A05, BC) : la page et le bon de commande PDF. Rien n'est écrit en base.
  def show
    # CHOIX : la langue par défaut reste :en tant que l'issue #20 n'a pas ajouté rails-i18n.
    # Cette page lit fr.yml. À retirer quand la locale par défaut sera :fr.
    I18n.locale = :fr
    @order = Order.includes(:buyer_company, :seller_company, :product, :address).find(params[:id])
    authorize @order

    respond_to do |format|
      format.html
      format.pdf { send_purchase_order }
    end
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

  def send_purchase_order
    send_data PurchaseOrderPdf.new(@order).render,
              filename: "#{@order.reference}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end
end
