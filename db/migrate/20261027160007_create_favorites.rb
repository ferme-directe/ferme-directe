# Jointure entreprise ↔ entreprise : deux clés vers la même table.
class CreateFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :favorites do |t|
      t.references :company, null: false, foreign_key: true
      t.references :favorite_company, null: false, foreign_key: { to_table: :companies }

      t.timestamps
    end
    add_index :favorites, %i[company_id favorite_company_id], unique: true
  end
end
