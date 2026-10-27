require "test_helper"

class FavoriteTest < ActiveSupport::TestCase
  test "une entreprise ne se met pas elle-même en favori" do
    favorite = Favorite.new(company: companies(:shop), favorite_company: companies(:shop))
    assert_not favorite.valid?
  end

  test "pas de doublon" do
    duplicate = Favorite.new(company: companies(:shop), favorite_company: companies(:farm))
    assert_not duplicate.valid?
  end
end
