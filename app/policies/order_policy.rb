# Qui a le droit de faire quoi sur une commande.
class OrderPolicy < ApplicationPolicy
  # Story 5 : seul quelqu'un de l'entreprise qui a publié le besoin peut commander.
  # Un compte sans entreprise ne peut pas commander (company_id vide).
  def create?
    user.company_id.present? && user.company_id == record.need.company_id
  end
end
