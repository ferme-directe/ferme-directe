require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  include ActiveJob::TestHelper

  setup do
    @order = orders(:eggs_order)
    ActionMailer::Base.deliveries.clear
  end

  test "deux e-mails sont mis en file pour l'acheteur et la ferme" do
    assert_enqueued_jobs 2, only: ActionMailer::MailDeliveryJob do
      @order.deliver_confirmations
    end
  end

  test "chaque e-mail joint le bon de commande" do
    perform_enqueued_jobs { @order.deliver_confirmations }

    mails = ActionMailer::Base.deliveries
    assert_equal [users(:buyer).email, users(:farmer).email].sort, mails.map { |mail| mail.to.first }.sort

    mails.each do |mail|
      attachment = mail.attachments.first
      assert_equal "Bon de commande #{@order.reference}", mail.subject
      assert_includes mail.text_part.body.decoded, @order.reference
      assert_equal ["bonjour@ferme-directe.test"], mail.from
      assert attachment
      assert_equal "#{@order.reference}.pdf", attachment.filename
      assert attachment.body.decoded.start_with?("%PDF")
    end
  end

  test "le corps HTML et le texte décrivent la commande" do
    perform_enqueued_jobs { @order.deliver_confirmations }

    mail = ActionMailer::Base.deliveries.first
    stamped_at = I18n.l(@order.created_at, format: "%d/%m/%Y %H:%M")

    [mail.text_part.body.decoded, mail.html_part.body.decoded].each do |body|
      assert_includes body, @order.reference
      assert_includes body, stamped_at
      assert_includes body, "Épicerie du Moulin"
      assert_includes body, "Ferme des Tilleuls"
      assert_includes body, "Œufs"
      assert_includes body, "0,36 €"
      assert_includes body, "108 €"
      assert_includes body, "Le fichier PDF est joint à ce message."
    end
  end
end
