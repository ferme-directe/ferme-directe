require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "pointe vers une commande ou vers un besoin" do
    assert_instance_of Order, notifications(:order_received).notifiable
    assert_instance_of Listing, notifications(:need_matched).notifiable
  end

  test "unread : celles dont read_at est vide" do
    notifications(:order_received).update!(read_at: Time.current)
    assert_equal [notifications(:need_matched)], users(:farmer).notifications.unread.to_a
  end
end
