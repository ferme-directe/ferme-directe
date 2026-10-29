# E-mail du bon de commande, un par destinataire, avec le PDF joint.
# CHOIX : locale :fr ici, parce que la tâche de fond ne reprend pas la langue de la requête.
# À retirer quand la locale par défaut sera :fr (issue #20).
class OrderMailer < ApplicationMailer
  # Adresse d'expéditeur tant que l'envoi Brevo n'est pas branché.
  default from: "Ferme Directe <bonjour@ferme-directe.test>"

  def confirmation(order, recipient)
    I18n.with_locale(:fr) { compose(order, recipient) }
  end

  private

  def compose(order, recipient)
    @order = order
    attachments["#{order.reference}.pdf"] = PurchaseOrderPdf.new(order).render
    mail to: recipient.email, subject: I18n.t("order_mailer.confirmation.subject", reference: order.reference)
  end
end
