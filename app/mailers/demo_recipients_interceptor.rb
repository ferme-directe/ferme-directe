# Démonstration : les comptes des seeds ont des adresses en .test (acheteur@ferme-directe.test,
# ferme1@…), qui n'existent pas. Juste avant l'envoi, cet intercepteur remplace ces adresses par de vraies
# boîtes, pour qu'on voie les e-mails arriver pendant la démo :
#   - l'adresse d'un compte qui vend (une ferme)  → DEMO_MAIL_FARM ;
#   - l'adresse de tout autre compte (acheteur)   → DEMO_MAIL_BUYER.
# Chaque variable accepte une ou plusieurs adresses, séparées par des virgules.
# Une vraie adresse (pas en .test) n'est jamais modifiée ; sans variable, rien n'est remplacé.
# Branché en production seulement (config/environments/production.rb).
# Interceptors : https://guides.rubyonrails.org/action_mailer_basics.html#intercepting-emails
class DemoRecipientsInterceptor
  DEMO_DOMAIN = ".test".freeze

  def self.delivering_email(message)
    message.to = message.to.flat_map { |address| replacement_for(address) }.uniq
  end

  def self.replacement_for(address)
    return [address] unless address.end_with?(DEMO_DOMAIN)

    variable = farm_address?(address) ? "DEMO_MAIL_FARM" : "DEMO_MAIL_BUYER"
    targets = ENV.fetch(variable, "").split(",").map(&:strip).compact_blank
    targets.presence || [address]
  end

  def self.farm_address?(address)
    User.find_by(email: address)&.company&.can_sell? || false
  end
end
