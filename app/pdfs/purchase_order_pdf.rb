# Bon de commande. La page le télécharge, l'e-mail de la story 8 joindra le même document.
# CHOIX : police DejaVu (vendor/fonts), licence dans DejaVu-LICENSE. La police
# intégrée à Prawn ne dessine pas les accents.
# CHOIX : Prawn ne lit pas le SCSS. sapin, terre et trait sont recopiés ici,
# une seule fois, depuis app/assets/stylesheets/config/_colors.scss.
require "prawn/table"

class PurchaseOrderPdf
  FONT = Rails.root.join("vendor/fonts/DejaVuSans.ttf")
  COLORS = { sapin: "2E463A", terre: "6E5443", trait: "E4DDD0" }.freeze

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

  # Titre = nom du site. En dessous : la référence, la date, les deux parties,
  # puis le tableau. Rien d'autre : un bon lisible suffit pour la démo.
  def draw(pdf)
    use_dejavu(pdf)
    draw_title(pdf)
    pdf.fill_color COLORS[:terre]
    heading_lines.each { |line| pdf.text line }
    pdf.move_down 16
    draw_table(pdf)
  end

  def draw_title(pdf)
    pdf.fill_color COLORS[:sapin]
    pdf.text I18n.t("app_name"), size: 18
    pdf.move_down 6
    pdf.stroke_color COLORS[:terre]
    pdf.stroke_horizontal_rule
    pdf.move_down 14
  end

  def draw_table(pdf)
    pdf.table(product_rows, width: pdf.bounds.width, header: true) do
      cells.border_color = COLORS[:trait]
      cells.text_color = COLORS[:sapin]
      row(0).background_color = COLORS[:trait]
    end
  end

  def use_dejavu(pdf)
    pdf.font_families.update("DejaVu" => { normal: FONT.to_s })
    pdf.font "DejaVu"
  end

  def heading_lines
    [
      I18n.t("orders.purchase_order.reference", reference: @order.reference),
      line(:date, I18n.l(stamped_at, format: "%d/%m/%Y %H:%M")),
      line(:buyer, @order.buyer_company.name),
      line(:seller, @order.seller_company.name)
    ]
  end

  def stamped_at
    @order.accepted_at || @order.created_at
  end

  def product_rows
    [
      [label(:product), label(:quantity), label(:unit_price), label(:total)],
      [
        @order.product.name,
        quantity,
        price(@order.unit_price_cents),
        price(@order.total_cents)
      ]
    ]
  end

  def quantity
    I18n.t("orders.purchase_order.quantity_value", quantity: @order.quantity, unit: @order.unit)
  end

  def line(key, value)
    "#{label(key)} : #{value}"
  end

  def label(key)
    I18n.t("orders.purchase_order.#{key}")
  end

  # Le même affichage que la page : format_price, pas un second calcul.
  def price(cents)
    ApplicationController.helpers.format_price(cents)
  end
end
