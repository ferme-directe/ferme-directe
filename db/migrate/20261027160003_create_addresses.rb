# Une entreprise a plusieurs adresses : facturation, livraison, lieu d'enlèvement.
# La distance entre une offre et un besoin se calcule sur latitude / longitude.
class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :company, null: false, foreign_key: true
      t.integer :kind, null: false
      t.string :label, null: false
      t.string :street, null: false
      t.string :postcode, null: false
      t.string :city, null: false
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
    add_index :addresses, %i[latitude longitude]
  end
end
