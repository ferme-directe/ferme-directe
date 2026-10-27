class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Facultative tant que l'inscription ne crée pas l'entreprise (cadrage, table users).
  belongs_to :company, optional: true
  has_many :notifications, dependent: :destroy
end
