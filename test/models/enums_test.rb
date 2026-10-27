require "test_helper"

# Les listes de valeurs du cadrage (bloc 4, « Les champs à liste de valeurs »).
# Ajouter, retirer ou renommer une valeur fait échouer ce test : la modification
# doit alors passer par le cadrage, puis par ce fichier, en connaissance de cause.
class EnumsTest < ActiveSupport::TestCase
  test "orders.status" do
    assert_equal %w[pending accepted declined cancelled], Order.statuses.keys
  end

  test "orders.fulfillment" do
    assert_equal %w[pickup delivery], Order.fulfillments.keys
  end

  test "listings.kind" do
    assert_equal %w[offer need], Listing.kinds.keys
  end

  test "listings.status" do
    assert_equal %w[active closed], Listing.statuses.keys
  end

  test "addresses.kind" do
    assert_equal %w[billing delivery pickup], Address.kinds.keys
  end

  test "notifications.kind" do
    assert_equal %w[order_received order_accepted order_declined need_matched], Notification.kinds.keys
  end

  test "chaque valeur a son libellé français" do
    I18n.with_locale(:fr) do
      { Order => %i[status fulfillment], Listing => %i[kind status], Address => %i[kind],
        Notification => %i[kind] }.each do |model, attributes|
        attributes.each do |attribute|
          model.public_send(attribute.to_s.pluralize).each_key do |value|
            key = "activerecord.attributes.#{model.model_name.i18n_key}/#{attribute}.#{value}"
            assert I18n.exists?(key, :fr), "Libellé manquant : #{key}"
          end
        end
      end
    end
  end

  test "human_enum lit le libellé français" do
    I18n.with_locale(:fr) do
      assert_equal "En attente", orders(:eggs_order).human_enum(:status)
    end
  end

  test "une valeur inconnue est refusée par la validation, sans exception" do
    order = orders(:eggs_order)
    order.status = "shipped"
    assert_not order.valid?
    assert_includes order.errors.attribute_names, :status
  end
end
