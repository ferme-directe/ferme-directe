require "test_helper"

# Les helpers de app/helpers/application_helper.rb.
# ActionView::TestCase donne accès aux helpers comme dans une vue.
class ApplicationHelperTest < ActionView::TestCase
  test "format_price affiche des euros au format français" do
    assert_equal "0,36 €", format_price(36)
    assert_equal "108 €", format_price(10_800)
    assert_equal "1 000 €", format_price(100_000)
  end

  test "status_tone donne la variante de l'étiquette selon le statut" do
    assert_equal "waiting", status_tone(orders(:eggs_order))
  end

  test "status_tone lève une erreur sur un statut absent de la table" do
    # Struct.new(:status) fabrique un petit objet qui n'a qu'un status : pas besoin
    # d'une vraie commande pour tester ce cas, seulement d'un statut inconnu.
    record = Struct.new(:status).new("inconnu")
    assert_raises(KeyError) { status_tone(record) }
  end

  test "user_initials prend le prénom et le nom, sinon l'e-mail" do
    assert_equal "PD", user_initials(users(:buyer))
    assert_equal "A", user_initials(User.new(email: "acheteur@ferme-directe.test"))
  end

  test "nav_link_to grise une rubrique qui n'a pas encore de page" do
    # assert_dom_equal compare deux morceaux de HTML comme le navigateur les lit :
    # l'ordre des attributs ou les espaces ne comptent pas.
    assert_dom_equal(
      %(<span class="nav-link site-navbar__link disabled" aria-disabled="true">Annonces</span>),
      nav_link_to("Annonces", nil)
    )
  end

  test "unit_label met l'unité au pluriel à partir de 2" do
    assert_equal "pièce", unit_label("pièce", 1)
    assert_equal "pièces", unit_label("pièce", 300)
    assert_equal "kilos", unit_label("kilo", 50)
  end

  test "unit_label connaît chaque unité de Listing::UNITS" do
    Listing::UNITS.each do |unit|
      assert_predicate unit_label(unit, 2), :present?, unit
      assert_predicate t("units.choice.#{unit}"), :present?, unit
    end
  end
end
