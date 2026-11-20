# Bon de commande. La page le télécharge, l'e-mail de la story 8 joindra le même document.
# Police, couleurs, bandeau avec le logo et pied de page : PdfBranding (app/pdfs/pdf_branding.rb).
require "prawn/table"

class PurchaseOrderPdf
  include PdfBranding

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

  # Mise en forme (20 nov.) : bandeau blé avec le logo, les deux parties dans deux encadrés,
  # le tableau du produit, le total mis en avant, un pied de page. Les données ne changent pas.
  def draw(pdf)
    use_dejavu(pdf)
    draw_header(pdf)
    draw_parties(pdf)
    draw_table(pdf)
    draw_total(pdf)
    draw_footer(pdf)
  end

  # Le bandeau du site, avec « Bon de commande » et la référence à droite ; la date en dessous.
  def draw_header(pdf)
    top = draw_brand_band(pdf)
    pdf.text_box label(:title).upcase, at: [0, top - 18], width: pdf.bounds.width - 20, align: :right, size: 9
    pdf.text_box @order.reference, at: [0, top - 32], width: pdf.bounds.width - 20, align: :right, size: 16
    pdf.move_cursor_to top - 90
    pdf.fill_color COLORS[:terre]
    pdf.text line(:date, I18n.l(stamped_at, format: "%d/%m/%Y %H:%M")), size: 10
    pdf.move_down 12
  end

  # Les deux parties côte à côte, chacune dans un encadré au filet « trait ».
  def draw_parties(pdf)
    top = pdf.cursor
    width = (pdf.bounds.width - 16) / 2
    [[:buyer, @order.buyer_company.name], [:seller, @order.seller_company.name]].each_with_index do |(key, name), i|
      x = i * (width + 16)
      pdf.stroke_color COLORS[:trait]
      pdf.stroke_rounded_rectangle [x, top], width, 54, 6
      pdf.fill_color COLORS[:terre]
      pdf.text_box label(key).upcase, at: [x + 12, top - 10], width: width - 24, size: 8
      pdf.fill_color COLORS[:sapin]
      pdf.text_box name, at: [x + 12, top - 24], width: width - 24, size: 13, height: 20, overflow: :shrink_to_fit
    end
    pdf.move_cursor_to top - 74
  end

  def draw_table(pdf)
    sapin, trait, papier = COLORS.values_at(:sapin, :trait, :papier)
    pdf.table(product_rows, width: pdf.bounds.width, header: true) do
      cells.border_color = trait
      cells.text_color = sapin
      cells.padding = [10, 10]
      row(0).background_color = sapin
      row(0).text_color = papier
      row(0).size = 9
      columns(2..3).align = :right
    end
  end

  # Le total sous le tableau, à droite, sur fond blé pâle.
  def draw_total(pdf)
    pdf.move_down 14
    top = pdf.cursor
    width = 200
    pdf.fill_color COLORS[:ble_pale]
    pdf.fill_rounded_rectangle [pdf.bounds.width - width, top], width, 40, 6
    pdf.fill_color COLORS[:sapin]
    pdf.text_box label(:total), at: [pdf.bounds.width - width + 12, top - 13], size: 11
    pdf.text_box price(@order.total_cents), at: [pdf.bounds.width - width, top - 11], width: width - 12,
                                            align: :right, size: 15
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
    unit = I18n.t("units.#{@order.unit}", count: @order.quantity)
    I18n.t("orders.purchase_order.quantity_value", quantity: @order.quantity, unit: unit)
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
