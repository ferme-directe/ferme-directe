class Product < ApplicationRecord
  has_many :listings, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :category, presence: true
  validates :default_unit, inclusion: { in: ->(_) { Listing::UNITS } }
end
