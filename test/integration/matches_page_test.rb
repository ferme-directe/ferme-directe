require "test_helper"

# La page des fermes d'un besoin (stories 2 et 3) : jusqu'ici, aucun test ne l'affichait.
# Filets posés après la relecture du 18 nov. : prix au format de la charte, textes traduits,
# et le cœur des favoris qui ramène sur cette page au lieu d'un 404 caché.
class MatchesPageTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:buyer)
    @need = listings(:eggs_need)
    @matches_page = need_matches_path(@need)
  end

  test "une offre sans assez de stock pour le besoin n'apparaît pas, même chez une ferme favorite" do
    offer = listings(:eggs_offer)
    get @matches_page
    assert_includes response.body, offer.company.name, "l'offre de départ doit apparaître"

    offer.update!(quantity: @need.quantity - 1)
    get @matches_page
    assert_not_includes response.body, offer.company.name

    offer.update!(quantity: 0, status: :closed)
    get @matches_page
    assert_not_includes response.body, offer.company.name
  end

  test "la page affiche les prix au format de la charte et ses textes en français" do
    offer = listings(:eggs_offer)
    get @matches_page

    assert_response :success
    assert_includes response.body, ApplicationController.helpers.format_price(offer.unit_price_cents)
    assert_includes response.body, ApplicationController.helpers.format_price(@need.quantity * offer.unit_price_cents)
    assert_includes response.body, I18n.t("matches.index.label")
    assert_includes response.body, I18n.t("matches.index.map_loading")
    assert_no_match(/\d\.\d+ €/, response.body, "un prix au format anglais (point décimal)")
  end

  test "le titre nomme le besoin et chaque fiche montre retrait, minimum et conditions de la ferme" do
    offer = listings(:eggs_offer)
    offer.update!(min_order_cents: 6000, delivery_terms: "Tournée le mardi, à convenir.")
    get @matches_page

    assert_select "h1", text: "#{@need.product.name} · 300 pièces"
    assert_includes response.body, offer.pickup_hours
    assert_includes response.body, "#{I18n.t('matches.index.min_order')} 60 €"
    assert_includes response.body, "Tournée le mardi, à convenir."
    assert_includes response.body, "pour 300 pièces"
    assert_no_match(/\d\.\d+ km/, response.body, "une distance au format anglais (point décimal)")
  end

  test "ajouter une ferme en favori ramène sur la liste des fermes du besoin" do
    post favorites_path, params: { favorite_company_id: companies(:other).id }, headers: { "Referer" => @matches_page }

    assert_redirected_to @matches_page
    follow_redirect!
    assert_response :success
  end

  test "retirer une ferme des favoris ramène sur la liste des fermes du besoin" do
    delete favorite_path(favorites(:shop_likes_farm)), headers: { "Referer" => @matches_page }

    assert_redirected_to @matches_page
    follow_redirect!
    assert_response :success
  end
end
