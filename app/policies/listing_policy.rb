class ListingPolicy < ApplicationPolicy
  def create?
    record.need? && user.company.present? && user.company.can_buy?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.offer
    end
  end
end
