require "test_helper"

# Le gabarit commun (app/views/layouts/application.html.erb) : la barre du haut
# dans ses deux états, et le pied de page, sur de vraies pages.
class LayoutTest < ActionDispatch::IntegrationTest
  # sign_in(user) : connecte un utilisateur sans passer par le formulaire (Devise).
  include Devise::Test::IntegrationHelpers

  test "un visiteur ne voit que le logo dans la barre" do
    get new_user_session_path

    assert_dom ".site-navbar .site-brand", text: "Ferme Directe"
    assert_dom ".site-navbar__link", count: 0
  end

  test "un utilisateur connecté voit les rubriques, la bascule et ses initiales" do
    sign_in users(:buyer)
    get root_path

    assert_dom "a.site-navbar__link", text: "Notifications"
    assert_dom "span.site-navbar__link.disabled", text: "Annonces"
    assert_dom ".site-navbar__role.active", text: "J'achète"
    assert_dom ".site-navbar__avatar", text: "PD"
  end

  test "le pied de page est sur chaque page" do
    get new_user_session_path

    assert_dom ".site-footer .site-footer__hosting", text: "Hébergement en France"
  end
end
