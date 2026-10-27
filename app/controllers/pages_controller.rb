class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  # controles: ok page d'accueil du template (pages#home)
  def home
  end
end
