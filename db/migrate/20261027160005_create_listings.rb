# Offres et besoins dans une seule table, distingués par kind (offer / need).
# Les champs propres à l'offre ou au besoin sont validés dans le modèle selon kind.
class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      t.references :company, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true
      t.integer :kind, null: false
      t.integer :status, null: false, default: 0
      t.string :label
      t.string :size
      t.integer :quantity, null: false
      t.string :unit, null: false
      t.integer :unit_price_cents
      t.integer :max_price_cents
      t.date :needed_on
      t.date :available_until
      t.integer :radius_km, null: false, default: 30
      t.integer :min_order_cents
      t.string :pickup_hours
      t.text :delivery_terms
      t.string :priorities, array: true, null: false, default: []

      t.timestamps
    end
    # La recherche de la story 2 filtre d'abord sur ces trois colonnes.
    add_index :listings, %i[kind status product_id]
  end
end
