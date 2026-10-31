require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @order = orders(:eggs_order)
    @offer = listings(:eggs_offer)
  end

  test "la fixture est valide" do
    assert @order.valid?
  end

  test "accept! passe la commande en acceptée, baisse le stock et prévient l'acheteur" do
    assert_difference -> { users(:buyer).notifications.count } => 1 do
      @order.accept!
    end

    assert @order.reload.accepted?
    assert_not_nil @order.accepted_at
    assert_equal 1200 - 300, @offer.reload.quantity
    assert @offer.active?
  end

  test "accept! ferme l'offre quand le stock tombe à zéro" do
    @offer.update!(quantity: 300)

    @order.accept!

    assert_equal 0, @offer.reload.quantity
    assert @offer.closed?
  end

  test "accept! refuse si le stock ne suffit plus, sans rien changer" do
    @offer.update!(quantity: 100)

    assert_no_difference -> { Notification.count } do
      assert_raises(ActiveRecord::RecordInvalid) { @order.accept! }
    end
    assert @order.errors.added?(:base, :out_of_stock)
    assert @order.reload.pending?
    assert_equal 100, @offer.reload.quantity
  end

  test "accept! refuse une commande qui n'est plus en attente" do
    @order.update!(status: :cancelled)

    assert_raises(ActiveRecord::RecordInvalid) { @order.accept! }
    assert @order.errors.added?(:base, :not_pending)
    assert_equal 1200, @offer.reload.quantity
  end
end
