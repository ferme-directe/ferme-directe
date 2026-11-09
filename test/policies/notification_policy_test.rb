require "test_helper"

class NotificationPolicyTest < ActiveSupport::TestCase
  test "chacun ne voit que ses notifications" do
    farmer_list = NotificationPolicy::Scope.new(users(:farmer), Notification).resolve

    assert_includes farmer_list, notifications(:order_received)
    assert_not_includes farmer_list, notifications(:order_accepted_read)
  end

  test "un compte sans notification a une liste vide, pas une erreur" do
    assert_empty NotificationPolicy::Scope.new(users(:stranger), Notification).resolve
  end
end
