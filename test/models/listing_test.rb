require "test_helper"

class ListingTest < ActiveSupport::TestCase
  test "les fixtures sont valides" do
    assert listings(:eggs_offer).valid?
    assert listings(:eggs_need).valid?
  end

  test "une offre exige un prix et une date de fin" do
    offer = listings(:eggs_offer)
    offer.unit_price_cents = nil
    offer.available_until = nil
    assert_not offer.valid?
    assert_includes offer.errors.attribute_names, :unit_price_cents
    assert_includes offer.errors.attribute_names, :available_until
  end

  test "un besoin exige une date" do
    need = listings(:eggs_need)
    need.needed_on = nil
    assert_not need.valid?
    assert_includes need.errors.attribute_names, :needed_on
  end

  test "le label vient de la liste fermée" do
    offer = listings(:eggs_offer)
    offer.label = "Extra-bio"
    assert_not offer.valid?
  end

  test "l'adresse doit appartenir à l'entreprise qui publie" do
    offer = listings(:eggs_offer)
    offer.address = addresses(:shop_delivery)
    assert_not offer.valid?
    assert_includes offer.errors.attribute_names, :address
  end
end
