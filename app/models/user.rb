class User < ApplicationRecord
  # Modules Devise. Pas de :registerable (story 14) : l'inscription avec création
  # d'entreprise est hors démo (cadrage), les comptes viennent des seeds. Le retirer
  # supprime les routes /users/sign_up et le lien « Sign up » des pages Devise.
  # Autres modules disponibles : :confirmable, :lockable, :timeoutable, :trackable, :omniauthable.
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  # Facultative tant que l'inscription ne crée pas l'entreprise (cadrage, table users).
  belongs_to :company, optional: true
  has_many :notifications, dependent: :destroy
end
