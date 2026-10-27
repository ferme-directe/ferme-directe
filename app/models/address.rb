class Address < ApplicationRecord
  belongs_to :company
  has_many :listings, dependent: :restrict_with_error

  enum :kind, { billing: 0, delivery: 1, pickup: 2 }, validate: true

  validates :label, :street, :city, presence: true
  validates :postcode, format: { with: /\A\d{5}\z/ }

  # Coordonnées par l'API Adresse de l'État (config/initializers/geocoder.rb).
  # Pas d'appel si les coordonnées sont déjà fournies (les seeds les donnent en dur).
  geocoded_by :full_address
  after_validation :geocode, if: :geocoding_needed?

  def full_address
    "#{street}, #{postcode} #{city}"
  end

  private

  def geocoding_needed?
    return latitude.blank? || longitude.blank? if new_record?

    will_save_change_to_street? || will_save_change_to_postcode? || will_save_change_to_city?
  end
end
