# Un palier de remise d'une offre. Le prix remisé se calcule, il ne se stocke pas.
class DiscountTier < ApplicationRecord
  belongs_to :listing, inverse_of: :discount_tiers

  validates :min_quantity, numericality: { only_integer: true, greater_than: 0 },
                           uniqueness: { scope: :listing_id }
  validates :discount_percent, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
end
