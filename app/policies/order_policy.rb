# Qui a le droit de faire quoi sur une commande.
class OrderPolicy < ApplicationPolicy
  # Story 5 : la commande se voit par l'acheteur et par la ferme, personne d'autre.
  def show?
    user.company_id.present? && [record.buyer_company_id, record.seller_company_id].include?(user.company_id)
  end

  # Story 5 : seul quelqu'un de l'entreprise qui a publié le besoin peut commander.
  # Un compte sans entreprise ne peut pas commander (company_id vide).
  def create?
    user.company_id.present? && user.company_id == record.need.company_id
  end
end
