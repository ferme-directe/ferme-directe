# Ce que Devise ne gère pas : le nom, le téléphone et l'entreprise de la personne.
# company_id peut être vide tant que l'inscription ne crée pas l'entreprise (cadrage).
class AddProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_reference :users, :company, foreign_key: true
  end
end
