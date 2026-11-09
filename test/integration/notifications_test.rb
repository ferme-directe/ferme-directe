require "test_helper"

# La liste des notifications et le compteur de la barre (story 9), sur de vraies requêtes.
class NotificationsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "un visiteur est renvoyé vers la connexion" do
    get notifications_path
    assert_redirected_to new_user_session_path
  end

  test "la ferme voit ses notifications, pas celles de l'acheteur" do
    sign_in users(:farmer)
    get notifications_path

    assert_response :success
    assert_dom "li.list-group-item", count: 2
    assert_dom "li.list-group-item strong", text: "Commande reçue"
    assert_dom "a[href=?]", order_path(orders(:eggs_order)), text: "Voir la commande"
    assert_dom "a[href=?]", need_matches_path(listings(:eggs_need)), text: "Voir les fermes"
    assert_dom ".tag--neutral", text: "Nouvelle", count: 2
  end

  test "le compteur de la barre compte les non lues, puis disparaît une fois la liste ouverte" do
    sign_in users(:farmer)

    get root_path
    assert_dom ".site-navbar__counter", text: "2"

    get notifications_path
    assert_dom ".site-navbar__counter", count: 0
    assert_not notifications(:order_received).reload.unread?
    assert_not notifications(:need_matched).reload.unread?
  end

  test "une notification déjà lue ne compte pas et n'est pas marquée nouvelle" do
    sign_in users(:buyer)

    get root_path
    assert_dom ".site-navbar__counter", count: 0

    get notifications_path
    assert_dom "li.list-group-item", count: 1
    assert_dom ".tag--neutral", count: 0
  end

  test "un compte sans notification voit le message vide" do
    sign_in users(:stranger)
    get notifications_path

    assert_response :success
    assert_dom "li.list-group-item", count: 0
    assert_includes response.body, "Aucune notification pour l'instant"
  end
end
