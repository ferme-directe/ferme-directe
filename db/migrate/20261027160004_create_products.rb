# Le référentiel des produits, rempli par les seeds : tout le monde choisit le même « Œufs ».
class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.string :default_unit, null: false

      t.timestamps
    end
    add_index :products, :name, unique: true
  end
end
