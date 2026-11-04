require "test_helper"

class OrdersShowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @order = orders(:eggs_order)
  end

  test "l'acheteur voit la référence et le récapitulatif tant que la commande est en attente" do
    sign_in users(:buyer)

    get order_path(@order)

    assert_response :success
    assert_includes response.body, @order.reference
    assert_includes response.body, "Œufs · Plein air · Gros"
    assert_includes response.body, "Ferme des Tilleuls"
    assert_includes response.body, "300 pièce"
    assert_includes response.body, "0,36 €"
    assert_includes response.body, "108 €"
    assert_includes response.body, "Retrait à la ferme"
    assert_equal 1, response.body.scan("En attente").size
    assert_select "a[href=?]", order_path(@order, format: :pdf), count: 0
  end

  test "une commande acceptée propose le bon de commande, sans répéter le statut" do
    sign_in users(:buyer)
    accepted_at = Time.zone.local(2026, 11, 3, 14, 30)
    @order.update!(status: :accepted, accepted_at: accepted_at)

    get order_path(@order)

    assert_response :success
    assert_includes response.body, I18n.l(accepted_at, format: "%d/%m/%Y %H:%M")
    assert_select "a.btn.btn-primary.btn-lg[href=?]", order_path(@order, format: :pdf), text: "Télécharger le bon de commande"
    assert_equal 1, response.body.scan("Acceptée").size
  end

  test "la ferme de la commande voit la référence" do
    sign_in users(:farmer)

    get order_path(@order)

    assert_response :success
    assert_includes response.body, @order.reference
  end

  test "l'acheteur télécharge le bon de commande" do
    sign_in users(:buyer)

    get order_path(@order, format: :pdf)

    assert_purchase_order_pdf
  end

  test "la ferme télécharge le bon de commande" do
    sign_in users(:farmer)

    get order_path(@order, format: :pdf)

    assert_purchase_order_pdf
  end

  test "un autre compte ne télécharge pas le bon" do
    sign_in users(:stranger)

    get order_path(@order, format: :pdf)

    assert_redirected_to root_path
    assert_not_equal "application/pdf", response.media_type
  end

  test "un autre compte est refusé" do
    sign_in users(:stranger)

    get order_path(@order)

    assert_redirected_to root_path
    assert_equal "Vous n'avez pas accès à cette page.", flash[:alert]
    follow_redirect!
    assert_not_includes response.body, @order.reference
  end

  private

  def assert_purchase_order_pdf
    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert response.body.start_with?("%PDF")
    assert_match "#{@order.reference}.pdf", response.headers["Content-Disposition"]
  end
end
