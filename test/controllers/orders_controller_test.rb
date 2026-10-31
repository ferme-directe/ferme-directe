require "test_helper"

# Story 6 : la ferme accepte une commande (PATCH /orders/:id/accept).
class OrdersControllerTest < ActionDispatch::IntegrationTest
  # sign_in(user) : connecte un utilisateur sans passer par le formulaire (Devise).
  include Devise::Test::IntegrationHelpers

  setup do
    @order = orders(:eggs_order)
  end

  test "la ferme accepte : la commande passe en acceptée" do
    sign_in users(:farmer)

    patch accept_order_path(@order)

    assert @order.reload.accepted?
    assert_redirected_to order_path(@order)
  end

  test "l'acheteur ne peut pas accepter sa propre commande" do
    sign_in users(:buyer)

    patch accept_order_path(@order)

    assert @order.reload.pending?
    assert_redirected_to root_path
  end

  test "un visiteur est renvoyé vers la connexion" do
    patch accept_order_path(@order)

    assert @order.reload.pending?
    assert_redirected_to new_user_session_path
  end

  test "stock insuffisant : la commande reste en attente, avec un message" do
    listings(:eggs_offer).update!(quantity: 100)
    sign_in users(:farmer)

    patch accept_order_path(@order)

    assert @order.reload.pending?
    assert_equal "Le stock de l'offre ne suffit plus pour cette commande.", flash[:alert]
  end

  test "sans DEMO_MODE, la route de démo n'existe pas" do
    assert_not Rails.application.routes.url_helpers.method_defined?(:demo_order_acceptance_path)
  end
end
