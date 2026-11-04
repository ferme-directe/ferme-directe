require "test_helper"

class OrderPolicyTest < ActiveSupport::TestCase
  setup do
    @order = orders(:eggs_order)
    @new_order = Order.build_from(need: listings(:eggs_need), offer: listings(:eggs_offer))
  end

  test "l'acheteur qui a publié le besoin peut commander" do
    assert OrderPolicy.new(users(:buyer), @new_order).create?
  end

  test "une autre entreprise ne peut pas commander sur ce besoin" do
    assert_not OrderPolicy.new(users(:farmer), @new_order).create?
  end

  test "un compte sans entreprise ne peut pas commander" do
    user = users(:buyer)
    user.company = nil

    assert_not OrderPolicy.new(user, @new_order).create?
  end

  test "l'acheteur et la ferme voient la commande, un compte sans entreprise non" do
    order = orders(:eggs_order)
    user = users(:buyer).dup.tap { |u| u.company = nil }

    assert OrderPolicy.new(users(:buyer), order).show?
    assert OrderPolicy.new(users(:farmer), order).show?
    assert_not OrderPolicy.new(user, order).show?
  end

  test "la ferme de la commande peut l'accepter" do
    assert OrderPolicy.new(users(:farmer), @order).accept?
  end

  test "l'acheteur ne peut pas accepter à la place de la ferme" do
    assert_not OrderPolicy.new(users(:buyer), @order).accept?
  end

  test "un compte sans entreprise ne peut pas accepter" do
    user = users(:farmer)
    user.company = nil

    assert_not OrderPolicy.new(user, @order).accept?
  end

  test "en démo, seul l'acheteur de la commande simule la réponse de la ferme" do
    assert OrderPolicy.new(users(:buyer), @order).demo_accept?
    assert_not OrderPolicy.new(users(:farmer), @order).demo_accept?
  end
end
