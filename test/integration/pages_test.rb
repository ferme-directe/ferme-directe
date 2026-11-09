require "test_helper"

# La page d'accueil (story 14) : réservée aux comptes connectés, et ce qu'elle montre.
# Un test d'intégration envoie une vraie requête : route, contrôleur, Devise, vue.
class PagesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "la page de connexion s'affiche" do
    get new_user_session_path
    assert_response :success
  end

  test "un visiteur est renvoyé vers la connexion" do
    get root_path
    assert_redirected_to new_user_session_path
  end

  test "un utilisateur connecté arrive sur l'accueil" do
    sign_in users(:buyer)
    get root_path

    assert_response :success
    assert_dom "h1", text: I18n.t("pages.home.title")
  end

  test "l'accueil ouvre les deux portes, j'achète et je vends" do
    sign_in users(:buyer)
    get root_path

    assert_dom "a.btn.btn-primary.btn-lg[href=?]", new_need_path, text: I18n.t("pages.home.buy.button")
    assert_dom "a.btn.btn-outline-secondary[href=?]", sales_path, text: I18n.t("pages.home.sell.button")
    assert_dom "img[alt=?]", I18n.t("pages.home.logo_alt")
  end

  test "une partie pas encore construite affiche « Pas encore ouvert » au lieu de planter" do
    sign_in users(:buyer)
    get sales_path

    assert_response :success
    assert_dom "h1", text: I18n.t("pages.soon.title")
    assert_dom "a.btn[href=?]", root_path, text: I18n.t("pages.soon.back")
  end

  test "la page « bientôt » est réservée aux connectés" do
    get soon_path
    assert_redirected_to new_user_session_path
  end

  test "l'inscription n'existe plus" do
    # Sans :registerable, Devise ne déclare ni la route ni son helper. En test,
    # une route inconnue répond 404 (show_exceptions = :rescuable), elle ne lève pas.
    assert_not Rails.application.routes.url_helpers.respond_to?(:new_user_registration_path)
    get "/users/sign_up"
    assert_response :not_found
  end
end
