require "test_helper"

# Story 5 : l'acheteur envoie sa commande (POST /needs/:need_id/orders).
class OrdersControllerTest < ActionDispatch::IntegrationTest
  # sign_in(user) : connecte un utilisateur sans passer par le formulaire (Devise).
  include Devise::Test::IntegrationHelpers

  setup do
    @need = listings(:eggs_need)
    @offer = listings(:eggs_offer)
  end

  test "l'acheteur envoie sa commande : elle est en attente et la ferme est prévenue" do
    sign_in users(:buyer)

    assert_difference -> { Order.count } => 1, -> { users(:farmer).notifications.count } => 1 do
      post need_orders_path(@need), params: { order: { offer_id: @offer.id, quantity: 300 } }
    end

    order = Order.order(:created_at).last
    assert order.pending?
    assert_equal 10_800, order.total_cents
    assert order.notifications.last.order_received?
    assert_redirected_to order_path(order)
  end

  test "une autre entreprise ne peut pas commander sur ce besoin" do
    sign_in users(:farmer)

    assert_no_difference -> { Order.count } do
      post need_orders_path(@need), params: { order: { offer_id: @offer.id, quantity: 300 } }
    end
    assert_redirected_to root_path
  end

  test "un visiteur est renvoyé vers la connexion" do
    assert_no_difference -> { Order.count } do
      post need_orders_path(@need), params: { order: { offer_id: @offer.id, quantity: 300 } }
    end
    assert_redirected_to new_user_session_path
  end

  test "une quantité nulle ne crée ni commande ni notification" do
    sign_in users(:buyer)

    assert_no_difference [-> { Order.count }, -> { Notification.count }] do
      post need_orders_path(@need), params: { order: { offer_id: @offer.id, quantity: 0 } }
    end
    assert_redirected_to need_matches_path(@need)
  end

  test "la page de la commande montre le statut, le récapitulatif et la suite" do
    sign_in users(:buyer)

    get order_path(orders(:eggs_order))

    assert_response :success
    assert_dom "h1", text: "Votre commande"
    assert_dom ".tag--waiting", text: "En attente"
    assert_dom "dd", text: "108 €"
    assert_dom ".card-title", text: "Et maintenant ?"
  end

  test "un compte qui n'est ni l'acheteur ni la ferme ne voit pas la commande" do
    users(:buyer).update!(company: nil)
    sign_in users(:buyer)

    get order_path(orders(:eggs_order))

    assert_redirected_to root_path
  end
end
