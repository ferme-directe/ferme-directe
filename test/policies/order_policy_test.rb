require "test_helper"

class OrderPolicyTest < ActiveSupport::TestCase
  setup do
    @order = orders(:eggs_order)
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
