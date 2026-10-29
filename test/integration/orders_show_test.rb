require "test_helper"

class OrdersShowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @order = orders(:eggs_order)
  end

  test "l'acheteur voit la référence, l'horodatage et le détail" do
    sign_in users(:buyer)

    get order_path(@order)

    assert_response :success
    assert_includes response.body, @order.reference
    assert_includes response.body, I18n.l(@order.created_at, format: "%d/%m/%Y %H:%M", locale: :fr)
    assert_includes response.body, "Œufs"
    assert_includes response.body, "Épicerie du Moulin"
    assert_includes response.body, "Ferme des Tilleuls"
    assert_includes response.body, "300 pièce"
    assert_includes response.body, "0,36 €"
    assert_includes response.body, "108,00 €"
    assert_includes response.body, "Retrait à la ferme"
    assert_includes response.body, "En attente"
    assert_includes response.body, "2 route de Dourdan"
  end

  test "la ferme de la commande voit la référence" do
    sign_in users(:farmer)

    get order_path(@order)

    assert_response :success
    assert_includes response.body, @order.reference
  end

  test "un autre compte est refusé" do
    sign_in users(:stranger)

    get order_path(@order)

    assert_redirected_to root_path
    assert_equal "Vous n'avez pas accès à cette page.", flash[:alert]
    follow_redirect!
    assert_not_includes response.body, @order.reference
  end
end
