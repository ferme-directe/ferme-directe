# Pointe vers une commande (order_received, order_accepted, order_declined)
# ou vers un besoin (need_matched, story 13).
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  enum :kind, { order_received: 0, order_accepted: 1, order_declined: 2, need_matched: 3 }, validate: true

  scope :unread, -> { where(read_at: nil) }
end
