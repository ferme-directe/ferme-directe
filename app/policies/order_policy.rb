# Qui a le droit de faire quoi sur une commande.
class OrderPolicy < ApplicationPolicy
  # Story 5 : la commande se voit par l'acheteur et par la ferme, personne d'autre.
  def show?
    member_of?(record.buyer_company_id) || member_of?(record.seller_company_id)
  end

  # Story 5 : seul quelqu'un de l'entreprise qui a publié le besoin peut commander.
  def create?
    member_of?(record.need.company_id)
  end

  # Story 6 : seule la ferme de la commande peut l'accepter.
  def accept?
    member_of?(record.seller_company_id)
  end

  # Outil de démo : l'acheteur simule la réponse de la ferme sur SA commande (route seulement si DEMO_MODE).
  def demo_accept?
    member_of?(record.buyer_company_id)
  end

  private

  # Un compte sans entreprise n'appartient à aucune (company_id vide).
  def member_of?(company_id)
    user.company_id.present? && user.company_id == company_id
  end
end
