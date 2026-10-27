Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  # Le routage complet du cadrage (bloc 2, « Le trajet de chaque story »).
  # Les contrôleurs existent, leurs actions sont vides : chaque story les remplit.

  # Stories 1, 2-3, 4-5 : le besoin, les fermes qui correspondent, la commande.
  resources :needs, only: %i[new create] do
    resources :matches, only: :index                 # GET /needs/:need_id/matches
    resources :orders, only: %i[new create]          # GET /needs/:need_id/orders/new, POST /needs/:need_id/orders
  end

  # Stories 7, 6, 10, 11 : la commande et ses changements d'état (member : une action sur UNE commande).
  resources :orders, only: :show do
    member do
      patch :accept                                  # PATCH /orders/:id/accept
      patch :decline                                 # PATCH /orders/:id/decline
      patch :cancel                                  # PATCH /orders/:id/cancel
    end
  end

  resources :notifications, only: :index             # story 9
  resources :sales, only: :index                     # story 12, « Mes ventes »

  # Outil de démo : le bouton « Simuler la réponse de la ferme ».
  # Ces routes n'existent que si DEMO_MODE est défini, jamais en production.
  if ENV["DEMO_MODE"].present?
    namespace :demo do
      resources :orders, only: [] do
        resource :acceptance, only: :create          # POST /demo/orders/:order_id/acceptance
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
