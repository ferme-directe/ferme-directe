# Le besoin de l'acheteur : une ligne de listings avec kind: need.
class NeedsController < ApplicationController
  # Story 1 (A01) : affiche le formulaire. Lit products et les adresses de l'entreprise.
  def new
    @need = Listing.new(kind: :need, address_id: current_user.company.addresses, radius_km: 30)
    authorize @need
    form_options
  end

  # Story 1 (A01) : enregistre le besoin, puis redirige vers /needs/:id/matches.
  # Story 13 : prévient ensuite les fermes qui peuvent le servir.
  def create
    # L'entreprise, le type et le statut sont fixés ici, jamais lus dans le formulaire.
    @need = Listing.new(need_params)
    @need.kind = :need
    @need.company = current_user.company
    authorize @need

    if @need.save
      redirect_to need_matches_path(@need)
    else
      form_options
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Les listes du formulaire. Appelée après authorize : un compte sans entreprise est refusé
  # avant d'arriver ici, au lieu de planter sur current_user.company.addresses.
  def form_options
    @products = Product.order(:category, :name)
    @addresses = current_user.company.addresses.where(kind: :delivery)
  end

  def need_params
    params.expect(listing: [:product_id, :label, :quantity, :unit, :needed_on, :address_id, :radius_km,
                            :max_price, { priorities: [] }])
  end
end
