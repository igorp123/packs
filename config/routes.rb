Rails.application.routes.draw do
  require 'sidekiq/web'

  root to: "drugs#index"

  resources :drugs do
    resources :batches
  end

  resources :sgtins, only: %i(destroy create)

  mount Sidekiq::Web => 'sidekiq'
end
