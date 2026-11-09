require "test_helper"

# Le gabarit commun (app/views/layouts/application.html.erb) : la barre du haut
# dans ses deux états, et le pied de page, sur de vraies pages.
class LayoutTest < ActionDispatch::IntegrationTest
  # sign_in(user) : connecte un utilisateur sans passer par le formulaire (Devise).
  include Devise::Test::IntegrationHelpers

  test "un visiteur ne voit que le logo dans la barre" do
    get new_user_session_path

    # assert_dom lit la page comme un navigateur et cherche par sélecteur CSS.
    # count: 0 : aucune rubrique ne doit apparaître pour un visiteur.
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

  test "le menu du compte propose de se déconnecter, en DELETE" do
    sign_in users(:buyer)
    get root_path

    # button_to produit un formulaire : la méthode DELETE est portée par un champ caché _method.
    assert_dom "form.button_to[action=?]", destroy_user_session_path do
      assert_dom "input[name=_method][value=delete]"
      assert_dom "button.dropdown-item", text: "Se déconnecter"
    end
  end

  test "la page de connexion est en français, sur la charte" do
    get new_user_session_path

    assert_dom "h1", text: "Connexion"
    assert_dom "input.btn.btn-primary.btn-lg[value=?]", "Connexion"
    assert_dom "a[href=?]", new_user_password_path, text: "Mot de passe oublié ?"
    assert_dom "a[href=?]", "/users/sign_up", count: 0
  end

  test "le pied de page est sur chaque page" do
    get new_user_session_path

    assert_dom ".site-footer .site-footer__hosting", text: "Hébergement en France"
  end
end
