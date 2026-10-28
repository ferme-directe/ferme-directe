require "test_helper"

# Le partial app/views/shared/_status_tag.html.erb, affiché seul.
class StatusTagTest < ActionView::TestCase
  test "une commande en attente : variante waiting, mot en français" do
    render partial: "shared/status_tag", locals: { record: orders(:eggs_order) }

    assert_dom "span.tag.tag--waiting", text: "En attente"
  end
end
