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
    record = Struct.new(:status).new("inconnu")
    assert_raises(KeyError) { status_tone(record) }
  end

  test "user_initials prend le prénom et le nom, sinon l'e-mail" do
    assert_equal "PD", user_initials(users(:buyer))
    assert_equal "A", user_initials(User.new(email: "acheteur@ferme-directe.test"))
  end

  test "nav_link_to grise une rubrique qui n'a pas encore de page" do
    assert_dom_equal(
      %(<span class="nav-link site-navbar__link disabled" aria-disabled="true">Annonces</span>),
      nav_link_to("Annonces", nil)
    )
  end
end
