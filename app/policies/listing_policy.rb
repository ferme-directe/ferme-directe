# Qui a le droit de publier une annonce (offre ou besoin).
class ListingPolicy < ApplicationPolicy
  # Story 1 : un besoin ne se publie que depuis une entreprise qui achète.
  # new? hérite de create? (ApplicationPolicy) : le formulaire suit la même règle.
  # CHOIX : seul le besoin est traité ; la story 4 ajoutera le cas de l'offre (can_sell).
  def create?
    record.need? && user.company.present? && user.company.can_buy?
  end
end
