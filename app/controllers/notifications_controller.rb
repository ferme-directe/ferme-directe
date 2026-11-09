# Les notifications de l'utilisateur connecté (story 9, barre du haut).
class NotificationsController < ApplicationController
  # Pseudo-code :
  #   1. ne garder que les siennes (policy_scope), les plus récentes d'abord, 50 au plus ;
  #   2. retenir lesquelles n'étaient pas encore lues, pour les marquer « Nouvelle » à l'écran ;
  #   3. les marquer toutes lues en base, en une seule requête ;
  #   4. afficher.
  # L'ordre 2 puis 3 compte : une fois l'écriture faite, plus rien ne distingue les nouvelles.
  def index
    @notifications = policy_scope(Notification).order(created_at: :desc).limit(50).to_a
    @new_ids = @notifications.select(&:unread?).map(&:id)

    # CHOIX : update_all plutôt qu'une boucle de save : une instruction SQL pour toutes les
    # lignes, et aucune validation à rejouer sur une simple date de lecture.
    policy_scope(Notification).unread.update_all(read_at: Time.current)
  end
end
