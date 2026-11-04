# Le bon de commande. Les données de l'accord sont recopiées de l'offre à la création
# (story 5) et ne bougent plus ensuite. Les changements d'état (accept!, decline!, cancel!)
# viennent avec les stories 6, 10 et 11.
class Order < ApplicationRecord
  belongs_to :buyer_company, class_name: "Company", inverse_of: :purchases
  belongs_to :seller_company, class_name: "Company", inverse_of: :sales
  belongs_to :need, class_name: "Listing", inverse_of: :orders_as_need
  belongs_to :offer, class_name: "Listing", inverse_of: :orders_as_offer
  belongs_to :product
  belongs_to :address
  has_many :notifications, as: :notifiable, dependent: :destroy

  enum :status, { pending: 0, accepted: 1, declined: 2, cancelled: 3 }, validate: true
  enum :fulfillment, { pickup: 0, delivery: 1 }, validate: true

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price_cents, :total_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :discount_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :unit, :needed_on, :payment_terms, presence: true
  validates :reference, presence: true, uniqueness: true

  # Story 5 : prépare la commande à partir du besoin de l'acheteur et de l'offre choisie.
  # Les données de l'accord sont recopiées : si la ferme change son prix demain, la commande ne bouge pas.
  # CHOIX : total = prix unitaire × quantité, sans remise par quantité pour l'instant (docs/a-faire-plus-tard.md).
  def self.build_from(need:, offer:, quantity: need.quantity)
    quantity = quantity.to_i
    new(
      need: need, offer: offer,
      buyer_company: need.company, seller_company: offer.company,
      product: offer.product, address: offer.address,
      label: offer.label, size: offer.size, unit: offer.unit, pickup_hours: offer.pickup_hours,
      quantity: quantity, unit_price_cents: offer.unit_price_cents, total_cents: offer.unit_price_cents * quantity,
      needed_on: need.needed_on, reference: generate_reference
    )
  end

  # Story 5 : enregistre la commande et prévient chaque compte de la ferme (notification « commande reçue »).
  # Tout ou rien : si une notification échoue, la commande n'est pas gardée non plus.
  # Renvoie la commande enregistrée, ou nil si elle est invalide (les erreurs sont dans order.errors).
  def place
    return unless valid?

    transaction do
      save!
      seller_company.users.each { |user| notifications.create!(user: user, kind: :order_received) }
    end
    self
  end

  # Une référence lisible sur le bon de commande : FD-20261031-A1B2C3.
  # La partie au hasard évite deux références identiques le même jour (l'index unique en base garantit le reste).
  def self.generate_reference
    "FD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(3).upcase}"
  end

  # Story 6 : la ferme accepte la commande.
  # Tout ou rien, dans une transaction :
  #   1. verrouiller la commande et l'offre (lock!, with_lock) : deux clics en même temps n'acceptent pas
  #      deux fois, et ne vendent pas deux fois le même stock ;
  #   2. refuser si la commande n'est plus en attente ou si le stock ne suffit plus ;
  #   3. baisser le stock (l'offre se ferme à zéro), passer la commande en accepted ;
  #   4. prévenir chaque compte de l'acheteur.
  # Lève ActiveRecord::RecordInvalid en cas de refus : le message est dans order.errors.
  def accept!
    transaction do
      lock!
      offer.with_lock do
        refuse!(:not_pending) unless pending?
        refuse!(:out_of_stock) if offer.quantity < quantity

        take_from_offer_stock!
        update!(status: :accepted, accepted_at: Time.current)
      end
      buyer_company.users.each { |user| notifications.create!(user: user, kind: :order_accepted) }
    end
  end

  private

  # Le stock baisse de la quantité commandée ; à zéro, l'offre se ferme.
  def take_from_offer_stock!
    remaining = offer.quantity - quantity
    offer.update!(quantity: remaining, status: remaining.zero? ? :closed : :active)
  end

  def refuse!(reason)
    errors.add(:base, reason)
    raise ActiveRecord::RecordInvalid, self
  end
end
