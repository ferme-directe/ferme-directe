require "test_helper"

# Vérifie que les pages s'affichent vraiment (layout, CSS, callbacks Pundit),
# ce que les tests de modèles ne voient pas.
class PagesTest < ActionDispatch::IntegrationTest
  test "la page de connexion s'affiche" do
    get new_user_session_path
    assert_response :success
  end

  test "la page d'accueil s'affiche (à adapter avec la story 14)" do
    get root_path
    assert_response :success
  end
end
