require "test_helper"

class NotificationsHelperTest < ActionView::TestCase
  test "une notification de commande mène à la commande" do
    notification = notifications(:order_received)

    assert_equal order_path(orders(:eggs_order)), notification_target_path(notification)
  end

  test "une notification de besoin mène aux fermes du besoin" do
    notification = notifications(:need_matched)

    assert_equal need_matches_path(listings(:eggs_need)), notification_target_path(notification)
  end
end
