# Les entreprises : fermes et acheteurs dans la même table, les rôles se cumulent (can_buy, can_sell).
# Seuls les champs du cœur de démo ; les champs optionnels du cadrage viendront avec leur story.
class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :siret
      t.text :description
      t.boolean :can_buy, null: false, default: true
      t.boolean :can_sell, null: false, default: false

      t.timestamps
    end
    add_index :companies, :siret, unique: true, where: "siret IS NOT NULL"
  end
end
