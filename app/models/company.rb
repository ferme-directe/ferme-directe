class Company < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :addresses, dependent: :destroy
  has_many :listings, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_companies, through: :favorites
  # Les commandes ne disparaissent pas avec l'entreprise : ce sont des bons de commande.
  has_many :purchases, dependent: :restrict_with_error,
                       class_name: "Order", foreign_key: :buyer_company_id, inverse_of: :buyer_company
  has_many :sales, dependent: :restrict_with_error,
                   class_name: "Order", foreign_key: :seller_company_id, inverse_of: :seller_company

  validates :name, presence: true
  validates :siret, format: { with: /\A\d{14}\z/ }, uniqueness: true, allow_blank: true
end
