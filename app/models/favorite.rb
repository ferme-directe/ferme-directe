class Favorite < ApplicationRecord
  belongs_to :company
  belongs_to :favorite_company, class_name: "Company"

  validates :favorite_company_id, uniqueness: { scope: :company_id }
  validate :not_itself

  private

  def not_itself
    errors.add(:favorite_company, :invalid) if favorite_company_id == company_id
  end
end
