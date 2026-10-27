# Une annonce : une offre (kind: offer, publiée par une ferme)
# ou un besoin (kind: need, publié par un acheteur).
class Listing < ApplicationRecord
  # Les listes fermées du cadrage. Une seule source : formulaires, validations et seeds lisent ces constantes.
  LABELS = ["Bio", "Label Rouge", "Plein air"].freeze
  SIZES = ["Gros", "Moyen", "Petit", "T65", "T80", "T110"].freeze
  UNITS = ["pièce", "kilo", "litre", "botte"].freeze
  PRIORITIES = %w[label distance price].freeze

  belongs_to :company
  belongs_to :product
  belongs_to :address
  has_many :discount_tiers, -> { order(:min_quantity) }, dependent: :destroy, inverse_of: :listing
  has_many :orders_as_need, dependent: :restrict_with_error,
                            class_name: "Order", foreign_key: :need_id, inverse_of: :need
  has_many :orders_as_offer, dependent: :restrict_with_error,
                             class_name: "Order", foreign_key: :offer_id, inverse_of: :offer
  has_many :notifications, as: :notifiable, dependent: :destroy

  enum :kind, { offer: 0, need: 1 }, validate: true
  enum :status, { active: 0, closed: 1 }, validate: true

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit, inclusion: { in: UNITS }
  validates :label, inclusion: { in: LABELS }, allow_blank: true
  validates :size, inclusion: { in: SIZES }, allow_blank: true
  validates :radius_km, numericality: { only_integer: true, greater_than: 0 }
  validates :max_price_cents, :min_order_cents, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :priorities_in_list
  validate :address_belongs_to_company

  with_options if: :offer? do
    validates :unit_price_cents, numericality: { only_integer: true, greater_than: 0 }
    validates :available_until, presence: true
  end

  with_options if: :need? do
    validates :needed_on, presence: true
  end

  private

  def priorities_in_list
    return if (priorities - PRIORITIES).empty?

    errors.add(:priorities, :inclusion)
  end

  def address_belongs_to_company
    return if address.nil? || address.company_id == company_id

    errors.add(:address, :invalid)
  end
end
