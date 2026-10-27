# Une notification s'adresse à une personne et pointe vers son objet :
# une commande (reçue, acceptée, refusée) ou un besoin (besoin compatible, story 13).
# Deux sortes d'objets : d'où la forme polymorphique (notifiable_type + notifiable_id).
class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :notifiable, polymorphic: true, null: false
      t.integer :kind, null: false
      t.datetime :read_at

      t.timestamps
    end
    # Le compteur de la barre : les notifications d'un utilisateur dont read_at est vide.
    add_index :notifications, %i[user_id read_at]
  end
end
