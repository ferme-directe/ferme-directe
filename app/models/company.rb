class Company < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :addresses, dependent: :destroy
  has_many :listings, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_companies, through: :favorites
  # Sa première offre : donne le dessin de la ferme en attendant ses photos (VisualsHelper).
  # Une association plutôt qu'une méthode, pour la précharger : includes(company: { main_offer: :product }).
  has_one :main_offer, -> { offer.order(:id) }, class_name: "Listing", inverse_of: false
  # Les commandes ne disparaissent pas avec l'entreprise : ce sont des bons de commande.
  has_many :purchases, dependent: :restrict_with_error,
                       class_name: "Order", foreign_key: :buyer_company_id, inverse_of: :buyer_company
  has_many :sales, dependent: :restrict_with_error,
                   class_name: "Order", foreign_key: :seller_company_id, inverse_of: :seller_company

  validates :name, presence: true
  validates :siret, format: { with: /\A\d{14}\z/ }, uniqueness: true, allow_blank: true
end
