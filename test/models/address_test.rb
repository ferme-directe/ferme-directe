require "test_helper"

class AddressTest < ActiveSupport::TestCase
  test "une nouvelle adresse sans coordonnées est géocodée (stub de test, aucun appel réseau)" do
    address = companies(:shop).addresses.create!(kind: :billing, label: "Siège", street: "1 rue de la Mairie",
                                                 postcode: "91530", city: "Sermaise")
    assert_in_delta 48.5333, address.latitude
  end

  test "le code postal garde son zéro et fait 5 chiffres" do
    address = addresses(:shop_delivery)
    address.postcode = "1530"
    assert_not address.valid?
  end
end
