require "test_helper"

class OrderPolicyTest < ActiveSupport::TestCase
  setup do
    @order = Order.build_from(need: listings(:eggs_need), offer: listings(:eggs_offer))
  end

  test "l'acheteur qui a publié le besoin peut commander" do
    assert OrderPolicy.new(users(:buyer), @order).create?
  end

  test "une autre entreprise ne peut pas commander sur ce besoin" do
    assert_not OrderPolicy.new(users(:farmer), @order).create?
  end

  test "un compte sans entreprise ne peut pas commander" do
    user = users(:buyer)
    user.company = nil

    assert_not OrderPolicy.new(user, @order).create?
  end

  test "l'acheteur et la ferme voient la commande, un compte sans entreprise non" do
    order = orders(:eggs_order)
    user = users(:buyer).dup.tap { |u| u.company = nil }

    assert OrderPolicy.new(users(:buyer), order).show?
    assert OrderPolicy.new(users(:farmer), order).show?
    assert_not OrderPolicy.new(user, order).show?
  end
end
