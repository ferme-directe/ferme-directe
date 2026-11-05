require "test_helper"

# Story 1 : le formulaire de besoin et son enregistrement. Qui y a accès, ce qui est écrit en base.
class NeedsControllerTest < ActionDispatch::IntegrationTest
  # sign_in(user) : connecte un utilisateur sans passer par le formulaire (Devise).
  include Devise::Test::IntegrationHelpers

  # Un besoin complet, tel que le formulaire l'envoie.
  def valid_params
    { listing: { product_id: products(:eggs).id, quantity: 300, unit: "pièce",
                 needed_on: 10.days.from_now.to_date, address_id: addresses(:shop_delivery).id,
                 radius_km: 30, priorities: ["distance"] } }
  end

  test "un visiteur est renvoyé vers la connexion" do
    get new_need_path

    assert_redirected_to new_user_session_path
  end

  test "une ferme qui n'achète pas est refusée" do
    sign_in users(:farmer)
    get new_need_path

    assert_redirected_to root_path
    assert_not_nil flash[:alert]
  end

  test "un acheteur voit le formulaire" do
    sign_in users(:buyer)
    get new_need_path

    assert_response :success
  end

  test "un besoin complet est enregistré pour l'entreprise de l'acheteur" do
    sign_in users(:buyer)

    assert_difference "Listing.count", 1 do
      post needs_path, params: valid_params
    end

    need = Listing.last
    assert need.need?
    assert_equal companies(:shop), need.company
    # On vérifie la redirection sans la suivre : la page des fermes est la story 2.
    assert_redirected_to need_matches_path(need)
  end

  test "un besoin incomplet n'est pas enregistré" do
    sign_in users(:buyer)
    params = valid_params
    params[:listing][:quantity] = ""

    assert_no_difference "Listing.count" do
      post needs_path, params: params
    end

    assert_response :unprocessable_entity
  end

  test "l'entreprise envoyée dans le formulaire est ignorée" do
    sign_in users(:buyer)
    params = valid_params
    params[:listing][:company_id] = companies(:farm).id

    post needs_path, params: params

    assert_equal companies(:shop), Listing.last.company
  end

  test "l'adresse d'une autre entreprise est refusée" do
    sign_in users(:buyer)
    params = valid_params
    params[:listing][:address_id] = addresses(:farm_pickup).id

    assert_no_difference "Listing.count" do
      post needs_path, params: params
    end

    assert_response :unprocessable_entity
  end
end
