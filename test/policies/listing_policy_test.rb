require "test_helper"

# Qui peut publier un besoin (story 1).
class ListingPolicyTest < ActiveSupport::TestCase
  test "un acheteur peut publier un besoin" do
    need = Listing.new(kind: :need, company: companies(:shop))

    assert ListingPolicy.new(users(:buyer), need).create?
  end

  test "une ferme qui n'achète pas ne peut pas publier un besoin" do
    need = Listing.new(kind: :need, company: companies(:farm))

    assert_not ListingPolicy.new(users(:farmer), need).create?
  end

  test "un compte sans entreprise ne peut pas publier un besoin" do
    user = User.new(email: "seul@ferme-directe.test", company: nil)

    assert_not ListingPolicy.new(user, Listing.new(kind: :need)).create?
  end
end
