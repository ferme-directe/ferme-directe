# L'identité visuelle des PDF du site : police, couleurs de la charte, bandeau avec le logo, pied de page.
# Ce qui est propre à un document (ses données, son tableau) reste dans sa classe : PurchaseOrderPdf.
# CHOIX : police DejaVu (vendor/fonts), licence dans DejaVu-LICENSE. La police
# intégrée à Prawn ne dessine pas les accents.
# CHOIX : Prawn ne lit pas le SCSS. Les couleurs de la charte sont recopiées ici,
# une seule fois, depuis app/assets/stylesheets/config/_colors.scss.
module PdfBranding
  FONT = Rails.root.join("vendor/fonts/DejaVuSans.ttf")
  COLORS = { sapin: "2E463A", terre: "6E5443", trait: "E4DDD0", ble: "D9B44A", ble_pale: "F5EACB",
             papier: "FBF8F1", gris_chaud: "6E655B" }.freeze
  # Le logo en PNG (Prawn ne lit pas le SVG) : le même fichier que celui des e-mails.
  LOGO = Rails.root.join("public/mail/logo-ferme-directe.png")

  private

  def use_dejavu(pdf)
    pdf.font_families.update("DejaVu" => { normal: FONT.to_s })
    pdf.font "DejaVu"
  end

  # Bandeau blé de 70 points de haut : le logo dans un rond et le nom du site à gauche.
  # Renvoie le haut du bandeau, pour que le document y pose ce qui va à droite.
  def draw_brand_band(pdf)
    top = pdf.cursor
    pdf.fill_color COLORS[:ble]
    pdf.fill_rounded_rectangle [0, top], pdf.bounds.width, 70, 8
    pdf.fill_color COLORS[:papier]
    pdf.fill_circle [44, top - 35], 24
    pdf.image LOGO.to_s, at: [24, top - 15], width: 40 if LOGO.exist?
    pdf.fill_color COLORS[:sapin]
    pdf.text_box I18n.t("app_name"), at: [80, top - 24], size: 20, height: 26
    top
  end

  def draw_footer(pdf)
    pdf.fill_color COLORS[:gris_chaud]
    pdf.stroke_color COLORS[:trait]
    pdf.stroke_horizontal_line 0, pdf.bounds.width, at: 24
    pdf.text_box I18n.t("mailer.footer"), at: [0, 16], width: pdf.bounds.width, size: 8, align: :center
  end
end
