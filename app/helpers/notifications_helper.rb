# Les méthodes d'affichage des notifications (story 9).
module NotificationsHelper
  # Où mène une notification : la commande, ou les fermes du besoin (story 13).
  # Construit depuis notifiable_type et notifiable_id, sans charger l'objet lié :
  # cinquante lignes, zéro requête de plus (Bullet n'a rien à signaler).
  # Un type inconnu lève une erreur : l'oubli casse un test au lieu d'afficher un lien mort.
  def notification_target_path(notification)
    case notification.notifiable_type
    when "Order" then order_path(notification.notifiable_id)
    when "Listing" then need_matches_path(notification.notifiable_id)
    else raise ArgumentError, "notifiable inconnu : #{notification.notifiable_type}"
    end
  end
end
