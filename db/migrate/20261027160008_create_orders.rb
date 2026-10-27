# Le bon de commande : relie un besoin et une offre, et fige les données de l'accord
# (produit, label, prix, total) pour qu'elles ne changent plus si l'offre change.
class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :buyer_company, null: false, foreign_key: { to_table: :companies }
      t.references :seller_company, null: false, foreign_key: { to_table: :companies }
      t.references :need, null: false, foreign_key: { to_table: :listings }
      t.references :offer, null: false, foreign_key: { to_table: :listings }
      t.references :product, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true
      t.string :label
      t.string :size
      t.string :unit, null: false
      t.integer :quantity, null: false
      t.integer :unit_price_cents, null: false
      t.integer :total_cents, null: false
      t.decimal :discount_percent, precision: 5, scale: 2, null: false, default: 0
      t.date :needed_on, null: false
      t.integer :fulfillment, null: false, default: 0
      t.string :pickup_hours
      t.string :payment_terms, null: false, default: "À la remise"
      t.string :reference, null: false
      t.integer :status, null: false, default: 0
      t.datetime :accepted_at
      t.datetime :declined_at
      t.datetime :cancelled_at

      t.timestamps
    end
    add_index :orders, :reference, unique: true
    # « Mes ventes » (story 12) et les commandes de l'acheteur filtrent par entreprise et par statut.
    add_index :orders, %i[seller_company_id status]
    add_index :orders, %i[buyer_company_id status]
  end
end
