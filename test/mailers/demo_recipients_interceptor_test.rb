require "test_helper"

# L'intercepteur de démo : les adresses en .test des comptes de démo sont remplacées par de vraies boîtes,
# celle de la ferme d'un côté, celle de l'acheteur de l'autre.
class DemoRecipientsInterceptorTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @saved = ENV.to_h.slice("DEMO_MAIL_BUYER", "DEMO_MAIL_FARM")
    ENV["DEMO_MAIL_BUYER"] = "acheteur-demo@example.com"
    ENV["DEMO_MAIL_FARM"] = "ferme-demo@example.com, ferme-demo-2@example.com"
  end

  teardown do
    %w[DEMO_MAIL_BUYER DEMO_MAIL_FARM].each { |name| ENV[name] = @saved[name] }
  end

  test "l'e-mail d'une ferme de démo part vers DEMO_MAIL_FARM, plusieurs adresses possibles" do
    mail = intercept(users(:farmer).email)

    assert_equal ["ferme-demo@example.com", "ferme-demo-2@example.com"], mail.to
  end

  test "l'e-mail d'un acheteur de démo part vers DEMO_MAIL_BUYER" do
    mail = intercept(users(:buyer).email)

    assert_equal ["acheteur-demo@example.com"], mail.to
  end

  test "une vraie adresse n'est jamais modifiée" do
    mail = intercept("quelquun@example.com")

    assert_equal ["quelquun@example.com"], mail.to
  end

  test "sans variable définie, l'adresse reste celle du compte" do
    ENV.delete("DEMO_MAIL_BUYER")
    mail = intercept(users(:buyer).email)

    assert_equal [users(:buyer).email], mail.to
  end

  test "sans MAIL_FROM, le bon de commande garde l'expéditeur de test" do
    assert_equal "Ferme Directe <bonjour@ferme-directe.test>", OrderMailer.default[:from]
  end

  test "les deux bons de commande d'une commande acceptée arrivent dans les deux boîtes de démo" do
    ActionMailer::Base.register_interceptor(DemoRecipientsInterceptor)
    ActionMailer::Base.deliveries.clear
    perform_enqueued_jobs { orders(:eggs_order).deliver_confirmations }

    recipients = ActionMailer::Base.deliveries.flat_map(&:to)
    assert_equal ["acheteur-demo@example.com", "ferme-demo-2@example.com", "ferme-demo@example.com"], recipients.sort
  ensure
    ActionMailer::Base.unregister_interceptor(DemoRecipientsInterceptor)
  end

  private

  def intercept(address)
    mail = Mail.new(to: address, from: "bonjour@ferme-directe.test", subject: "Essai")
    DemoRecipientsInterceptor.delivering_email(mail)
    mail
  end
end
