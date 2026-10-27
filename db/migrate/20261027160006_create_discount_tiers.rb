# Les paliers de remise d'une offre : « dès 500 pièces, 5 % ». Barème public.
class CreateDiscountTiers < ActiveRecord::Migration[8.1]
  def change
    create_table :discount_tiers do |t|
      t.references :listing, null: false, foreign_key: true
      t.integer :min_quantity, null: false
      t.decimal :discount_percent, precision: 5, scale: 2, null: false

      t.timestamps
    end
    add_index :discount_tiers, %i[listing_id min_quantity], unique: true
  end
end
