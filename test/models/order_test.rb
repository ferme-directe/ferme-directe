require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "la fixture est valide" do
    assert orders(:eggs_order).valid?
  end

  test "build_from recopie les données de l'offre et du besoin" do
    order = Order.build_from(need: listings(:eggs_need), offer: listings(:eggs_offer))

    assert order.valid?, order.errors.full_messages.to_sentence
    assert order.pending?
    assert_equal companies(:shop), order.buyer_company
    assert_equal companies(:farm), order.seller_company
    assert_equal products(:eggs), order.product
    assert_equal 36, order.unit_price_cents
    assert_equal 300, order.quantity
    assert_equal listings(:eggs_need).needed_on, order.needed_on
  end

  test "le total vaut prix unitaire × quantité" do
    order = Order.build_from(need: listings(:eggs_need), offer: listings(:eggs_offer), quantity: 100)

    assert_equal 3600, order.total_cents
  end

  test "deux commandes n'ont pas la même référence" do
    first = Order.build_from(need: listings(:eggs_need), offer: listings(:eggs_offer))
    second = Order.build_from(need: listings(:eggs_need), offer: listings(:eggs_offer))

    assert_match(/\AFD-\d{8}-[0-9A-F]{6}\z/, first.reference)
    assert_not_equal first.reference, second.reference
  end

  test "une quantité nulle est refusée" do
    order = Order.build_from(need: listings(:eggs_need), offer: listings(:eggs_offer), quantity: 0)

    assert_not order.valid?
    assert_includes order.errors.attribute_names, :quantity
  end
end
