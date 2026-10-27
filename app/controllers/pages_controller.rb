class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home # controles: ok page d'accueil du template (pages#home)
  end
end
