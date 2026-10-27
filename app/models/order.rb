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
end
