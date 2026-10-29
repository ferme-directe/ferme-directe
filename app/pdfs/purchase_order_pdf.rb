# Bon de commande. La page le télécharge, l'e-mail de la story 8 joindra le même document.
# CHOIX : police DejaVu (vendor/fonts), licence dans DejaVu-LICENSE. La police
# intégrée à Prawn ne dessine pas les accents.
require "prawn/table"

class PurchaseOrderPdf
  include ActionView::Helpers::NumberHelper

  FONT = Rails.root.join("vendor/fonts/DejaVuSans.ttf")

  def initialize(order)
    @order = order
  end

  def render
    document.render
  end

  private

  def document
    Prawn::Document.new(page_size: "A4") { |pdf| draw(pdf) }
  end

  def draw(pdf)
    use_dejavu(pdf)
    pdf.text I18n.t("orders.show.title", reference: @order.reference), size: 18
    pdf.move_down 12
    detail_lines.each { |line| pdf.text line }
    pdf.move_down 16
    pdf.table(product_rows, width: pdf.bounds.width, header: true)
    pdf.move_down 16
    pdf.text address_line
  end

  def use_dejavu(pdf)
    pdf.font_families.update("DejaVu" => { normal: FONT.to_s })
    pdf.font "DejaVu"
  end

  def detail_lines
    stamped_at = @order.accepted_at || @order.created_at
    [
      line(:timestamp, I18n.l(stamped_at, format: "%d/%m/%Y %H:%M")),
      line(:buyer, @order.buyer_company.name),
      line(:seller, @order.seller_company.name),
      line(:fulfillment, @order.human_enum(:fulfillment)),
      line(:status, @order.human_enum(:status))
    ]
  end

  def product_rows
    [
      [label(:product), label(:label), label(:quantity), label(:unit_price), label(:total)],
      [
        @order.product.name,
        @order.label.to_s,
        quantity,
        euros(@order.unit_price_cents),
        euros(@order.total_cents)
      ]
    ]
  end

  def address_line
    address = @order.address
    "#{label(:address)} : #{address.street}, #{address.postcode} #{address.city}"
  end

  def quantity
    I18n.t("orders.show.quantity_value", quantity: @order.quantity, unit: @order.unit)
  end

  def line(key, value)
    "#{label(key)} : #{value}"
  end

  def label(key)
    I18n.t("orders.show.#{key}")
  end

  def euros(cents)
    number_to_currency(BigDecimal(cents) / 100)
  end
end
