# Décision 9 du cadrage : tout migrer dès le socle, champs optionnels compris, pour que
# personne n'ait à toucher db/schema.rb à cinq en parallèle. Ces champs sont nullables et
# sans validation : aucun écran de la démo ne les utilise.
#
# Non créés ici : companies.photos (Active Storage, à installer avec la story qui l'utilise),
# orders.recurrence_id (la table recurrences est en réserve), et les 4 tables en réserve.
class AddOptionalFields < ActiveRecord::Migration[8.1]
  def change
    change_table :companies, bulk: true do |t|
      t.string :legal_form
      t.string :naf_code
      t.string :vat_number
      t.boolean :vat_exempt, null: false, default: false
      t.string :administrative_status
      t.datetime :siret_verified_at
      t.text :certifications
      t.text :production_method
    end

    add_column :products, :processed, :boolean, null: false, default: false

    change_table :listings, bulk: true do |t|
      t.integer :nature, null: false, default: 0
      t.integer :storage
      t.text :free_text
      t.uuid :group_id
    end
    add_index :listings, :group_id

    change_table :orders, bulk: true do |t|
      t.string :lot_number
      t.date :best_before
      t.datetime :delivered_at
    end
  end
end
