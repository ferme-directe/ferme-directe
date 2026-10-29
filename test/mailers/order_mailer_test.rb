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
end
