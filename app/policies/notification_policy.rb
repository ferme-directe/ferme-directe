# Qui voit quelles notifications : chacun les siennes, et rien d'autre (story 9).
# Il n'y a pas d'action sur une notification isolée (pas de show, pas de destroy) :
# seule la Scope compte, c'est elle que policy_scope appelle sur index.
class NotificationPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    # La liste ne peut contenir que les notifications adressées à l'utilisateur connecté.
    # Un compte sans notification obtient une relation vide, pas une erreur.
    def resolve
      scope.where(user: user)
    end
  end
end
