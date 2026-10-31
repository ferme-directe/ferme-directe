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
  # Champs optionnels du cadrage, hors démo : entraide entre fermes, conservation.
  enum :nature, { sale: 0, helping_hand: 1 }, validate: true
  # prefix : « frozen » donnerait frozen?, déjà défini par Ruby. Méthodes : storage_fresh?, storage_frozen?…
  enum :storage, { fresh: 0, dry: 1, frozen: 2 }, prefix: true, validate: { allow_nil: true }

  # Un besoin demande au moins 1 ; le stock d'une offre peut tomber à 0 quand la ferme accepte (story 6).
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }, if: :need?
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :offer?
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
