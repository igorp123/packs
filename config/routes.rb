Rails.application.routes.draw do
  root to: "drugs#index"

  resources :drugs do
    resources :batches
  end

  resources :sgtins, only: :destroy
end

