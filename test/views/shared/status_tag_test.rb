require "test_helper"

# Le partial app/views/shared/_status_tag.html.erb, affiché seul.
class StatusTagTest < ActionView::TestCase
  test "une commande en attente : variante waiting, mot en français" do
    # render partial: affiche le partial seul, avec la commande des fixtures.
    render partial: "shared/status_tag", locals: { record: orders(:eggs_order) }

    # assert_dom cherche dans le HTML produit un élément qui correspond au sélecteur CSS
    # (un <span> qui a les classes tag et tag--waiting) et contient ce texte.
    assert_dom "span.tag.tag--waiting", text: "En attente"
  end
end
