class FavoritePolicy < ApplicationPolicy
  def create?
    user&.company.present? &&
      record.company_id == user.company.id &&
      record.favorite_company_id.present? &&
      record.favorite_company_id != user.company.id
  end

  def destroy?
    user&.company.present? &&
      record.company_id == user.company.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user&.company

      scope.where(company_id: user.company_id)
    end
  end
end
