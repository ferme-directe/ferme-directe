# Qui peut voir une commande : l'entreprise acheteuse ou la ferme vendeuse.
# Tout autre compte est refusé, même s'il connaît l'adresse de la page.
class OrderPolicy < ApplicationPolicy
  def show?
    party?
  end

  private

  def party?
    company_id = user.company_id
    company_id.present? && (company_id == record.buyer_company_id || company_id == record.seller_company_id)
  end
end
